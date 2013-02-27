require 'pg'
require 'cf-runtime/properties'
module CFRuntime
  class PGClient

    # Creates and returns a +PGconn+ connecting to a single postgresql service.
    # Passes optional Hash of non-connection-related options to +PGconn.open+.
    # Raises +ArgumentError+ If zero or multiple postgresql services are found.
    def self.create(options={})
      service_names = CloudApp.service_names_of_type('postgresql')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of postgresql type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      cfoptions = options_for_svc(service_names[0],options)
      #Pass back the options for verification
      yield cfoptions if block_given?
      PGconn.open(cfoptions)
    end

    # Creates and returns a +PGconn+ connecting to a postgresql service with the
    # specified name.
    # Passes optional Hash of non-connection-related options to +PGconn.open+.
    # Raises +ArgumentError+ If specified postgresql service is not found.
    def self.create_from_svc(service_name,options={})
      cfoptions = options_for_svc(service_name,options)
      #Pass back the options for verification
      yield cfoptions if block_given?
      PGconn.open(cfoptions)
    end

    # Merges provided options with connection options for specified postgresql service.
    # Returns merged Hash containing (:user, :password, :dbname, :host, :port).
    # Raises +ArgumentError+ If specified postgresql service is not found.
    def self.options_for_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = options
      cfoptions[:host] = service_props[:host]
      cfoptions[:port] = service_props[:port]
      cfoptions[:user] = service_props[:username]
      cfoptions[:password] = service_props[:password]
      cfoptions[:dbname] = service_props[:database]
      cfoptions
    end
  end
end
