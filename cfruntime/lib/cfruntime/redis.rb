require 'redis'
require 'cfruntime/properties'
module CFRuntime
  class RedisClient

    def self.create(options={})
      service_props = CloudApp.service_props('redis')
      #TODO how to know too many/too few
      if service_props.nil?
        raise ArgumentError.new("Not the right number of clients")
      end
      cfoptions = merge_options(options, service_props)
      Redis.new(cfoptions)
    end

    def self.create_from_svc(service_name, options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = merge_options(options, service_props)
      Redis.new(cfoptions)
    end

    def self.merge_options(options, service_props)
      #Merge takes care of replacing host,port,password
      cfoptions = options.merge(service_props)
       if !cfoptions[:path].nil?
         #Host and port are ignored if a path is specified
         cfoptions[:path] = "#{service_props[:host]}:#{service_props[:port]}"
       end
       cfoptions
    end
  end
end