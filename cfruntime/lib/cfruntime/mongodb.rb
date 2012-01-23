require 'mongo'
require 'cfruntime/properties'
module CFRuntime
  class MongoClient

    # Creates and returns a Mongo +Connection+ to a single mongodb service.
    # Passes optional Hash of non-connection-related options to +Mongo::Connection.new+.
    # The connection is wrapped in a proxy that adds a no-argument db method to gain access
    # to the database created by CloudFoundry without having to specify the name.
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
    # The connection is wrapped in a proxy that adds a no-argument db method to gain access
    # to the database created by CloudFoundry without having to specify the name.
    # Raises +ArgumentError+ If specified mongodb service is not found.
    def self.create_from_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      uri = "mongodb://#{service_props[:username]}:#{service_props[:password]}@#{service_props[:host]}:#{service_props[:port]}/#{service_props[:db]}"
      conn = Mongo::Connection.from_uri(uri, options)
      MongoConnection.new(conn, service_props[:db])
    end

    # Returns the db_name for a single mongodb service.
    # Raises +ArgumentError+ If zero or multiple mongodb services are found.
    def self.db_name()
      service_names = CloudApp.service_names_of_type('mongodb')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of mongodb type, " +
          "but found #{service_names.length}.  " +
          "Consider using db_name_from_svc(service_name) instead.")
      end
      db_name_from_svc(service_names[0],connection)
    end

    # Returns the db_name for the mongodb service with the specified name.
    # Raises +ArgumentError+ If specified mongodb service is not found.
    def self.db_from_svc(service_name,connection)
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      service_props[:db]
    end

  end

  class MongoConnection

    instance_methods.each { |m| undef_method m unless m =~ /^__|instance_eval|object_id/ }

    def initialize(connection, db_name)
      @target = connection
      @dbname = db_name
    end

    def db(db_name=@dbname, opts={})
      @target.send('db', db_name, opts)
    end

    protected

      def method_missing(method, *args, &block)
        @target.send(method, *args, &block)
      end

  end

end