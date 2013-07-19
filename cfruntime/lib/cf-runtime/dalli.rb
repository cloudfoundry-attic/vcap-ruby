require 'dalli'
require 'cf-runtime/properties'
module CFRuntime
  class DalliClient

    # Creates and returns a +Dalli::Client+ instance connected to a single memcached service.
    # Passes optional Hash of non-connection-related options to +Dalli::Client.new+.
    # Raises +ArgumentError+ If zero or multiple memcached services are found.
    def self.create(options={})
      service_names = CloudApp.service_names_of_type('memcached')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of memcached type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      create_from_svc(service_names[0],options)
    end

    # Creates and returns a +Dalli::Client+ instance connected to a memcached service with the
    # specified name.
    # Passes optional Hash of non-connection-related options to +Dalli::Client.new+.
    # Raises +ArgumentError+ If specified memcached service is not found.
    def self.create_from_svc(service_name, options={})
      Dalli::Client.new(*options_for_svc(service_name,options))
    end

    # Merges provided options with connection options for specified memcached service.
    # Returns merged Array containing ( host:port, { username, password })
    # Raises +ArgumentError+ If specified memcached service is not found.
    def self.options_for_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = []
      cfoptions[0] = [service_props[:host], service_props[:port]].join(':')
      cfoptions[1] = options
      cfoptions[1][:username] = service_props[:username]
      cfoptions[1][:password] = service_props[:password]
      cfoptions
    end
  end
end
