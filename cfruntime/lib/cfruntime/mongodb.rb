require 'mongo'
require 'cfruntime/properties'
module CFRuntime
  class MongoClient

    def self.create(options={})
      service_props = CloudApp.service_props('mongodb')
      #TODO how to know too many/too few
      if service_props.nil?
        raise ArgumentError.new("Not the right number of clients")
      end
      create_db(service_props,options)
    end

    def self.create_from_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      create_db(service_props,options)
    end

    private
    def self.create_db(service_props,options)
      db = Mongo::Connection.new(service_props[:host], service_props[:port],options).db(service_props[:db])
      db.authenticate(service_props[:username],service_props[:password])
      db
    end
  end
end