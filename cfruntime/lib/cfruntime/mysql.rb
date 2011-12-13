require 'mysql2'
require 'cfruntime/properties'
module CFRuntime
  class Mysql2Client

    def self.create(options={})
      service_props = CloudApp.service_props('mysql')
      #TODO how to know too many/too few
      if service_props.nil?
        raise ArgumentError.new("Not the right number of clients")
      end
      cfoptions = merge_options(options, service_props)
      Mysql2::Client.new(cfoptions)
    end

    def self.create_from_svc(service_name, options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = merge_options(options, service_props)
      Mysql2::Client.new(cfoptions)
    end

    def self.merge_options(options, service_props)
      #mysql opts keys and service_props keys are the same
      options.merge(service_props)
    end
  end
end