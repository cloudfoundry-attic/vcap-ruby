require 'mongo'
require 'cfruntime/properties'
module CFRuntime
  class MongoClient

    # Creates and returns a Mongo +Connection+ to a single mongodb service.
    # Passes optional Hash of non-connection-related options to +Mongo::Connection.new+.
    # Raises +ArgumentError+ If zero or multiple mongodb services are found.
    def self.create(options={})
      service_names = CloudApp.service_names_of_type('mongodb')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of mongodb type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      create_from_svc(service_names[0],options)
    end

    # Creates and returns a Mongo +Connection+ to a mongodb service with the
    # specified name.
    # Passes optional Hash of non-connection-related options to +Mongo::Connection.new+.
    # Raises +ArgumentError+ If specified mongodb service is not found.
    def self.create_from_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      Mongo::Connection.new(service_props[:host], service_props[:port],options)
    end

    # Creates and returns an authenticated Mongo +DB+ instance connected to a single mongodb service
    # Raises +ArgumentError+ If zero or multiple mongodb services are found.
    def self.db(connection)
      service_names = CloudApp.service_names_of_type('mongodb')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of mongodb type, " +
          "but found #{service_names.length}.  " +
          "Consider using db_from_svc(service_name) instead.")
      end
      db_from_svc(service_names[0],connection)
    end

    # Creates and returns an authenticated Mongo +DB+ instance connected to a mongodb service with the
    # specified name.
    # Raises +ArgumentError+ If specified mongodb service is not found.
    def self.db_from_svc(service_name,connection)
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      db = connection.db(service_props[:db])
      db.authenticate(service_props[:username],service_props[:password])
      db
    end


  end
end