require 'amqp'
module CFRuntime
  class AMQPClient

    def self.create(other_options = {}, &block)
      service_props = CloudApp.service_props('rabbitmq')
      #TODO how to know too many/too few
      if service_props.nil?
        raise ArgumentError.new("Not the right number of clients")
      end
      cfoptions = merge_options({}, service_props)
      AMQP.connect(cfoptions, other_options, &block)
    end

    def self.create_from_svc(service_name, other_options = {}, &block)
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = merge_options({}, service_props)
      AMQP.connect(cfoptions, other_options, &block)
    end

    def self.merge_options(options, service_props)
      cfoptions = options
      cfoptions[:host] = service_props[:host]
      cfoptions[:port] = service_props[:port]
      cfoptions[:user] = service_props[:username]
      cfoptions[:pass] = service_props[:password]
      cfoptions[:vhost] = service_props[:vhost]
      cfoptions
    end
  end
end