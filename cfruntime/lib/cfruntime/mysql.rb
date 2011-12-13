require 'mysql2'
require 'cfruntime/properties'
module CFRuntime
  class Mysql2Client

    # Creates and returns a Mysql2 +Client+ instance connected to a single mysql service.
    # Passes optional Hash of non-connection-related options to +Mysql2::Client.new+.
    # Raises +ArgumentError+ If zero or multiple mysql services are found.
    def self.create(options={})
      service_names = CloudApp.service_names_of_type('mysql')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of mysql type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      create_from_svc(service_names[0],options)
    end

    # Creates and returns a Mysql2 +Client+ instance connected to a mysql service with the
    # specified name.
    # Passes optional Hash of non-connection-related options to +Mysql2::Client.new+.
    # Raises +ArgumentError+ If specified mysql service is not found.
    def self.create_from_svc(service_name, options={})
      Mysql2::Client.new(options_for_svc(service_name,options))
    end

    # Merges provided options with connection options for specified mysql service.
    # Returns merged Hash containing (:username, :password, :database, :host, :port).
    # Raises +ArgumentError+ If specified mysql service is not found.
    def self.options_for_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = options
      cfoptions[:host] = service_props[:host]
      cfoptions[:port] = service_props[:port]
      cfoptions[:username] = service_props[:username]
      cfoptions[:password] = service_props[:password]
      cfoptions[:database] = service_props[:database]
      cfoptions
    end
  end
end