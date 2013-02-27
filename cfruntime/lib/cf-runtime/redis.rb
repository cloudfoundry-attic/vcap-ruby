require 'redis'
require 'cf-runtime/properties'
module CFRuntime
  class RedisClient

    # Creates and returns a +Redis+ instance connected to a single redis service.
    # Passes optional Hash of non-connection-related options to +Redis.new+.
    # Raises +ArgumentError+ If zero or multiple redis services are found.
    def self.create(options={})
      service_names = CloudApp.service_names_of_type('redis')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of redis type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      create_from_svc(service_names[0],options)
    end

    # Creates and returns a +Redis+ instance connected to a redis service with the
    # specified name.
    # Passes optional Hash of non-connection-related options to +Redis.new+.
    # Raises +ArgumentError+ If specified redis service is not found.
    def self.create_from_svc(service_name, options={})
      Redis.new(options_for_svc(service_name,options))
    end

    # Merges provided options with connection options for specified redis service.
    # Returns merged Hash containing (password, :host, :port)
    # Raises +ArgumentError+ If specified redis service is not found.
    def self.options_for_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = options
      cfoptions[:host] = service_props[:host]
      cfoptions[:port] = service_props[:port]
      cfoptions[:password] = service_props[:password]
      #host and port are ignored if path is provided, so we null it out
      cfoptions[:path] = nil
      cfoptions
    end
  end
end
