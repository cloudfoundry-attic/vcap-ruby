require 'amqp'
require 'cf-runtime/properties'
module CFRuntime
  class AMQPClient

    # Creates and returns an +AMQP+ connection to a single rabbitmq service.
    # Passes optional other_options and block arguments to +AMQP.connect+.
    # Raises +ArgumentError+ If zero or multiple rabbitmq services are found.
    def self.create(other_options = {}, &block)
      service_names = CloudApp.service_names_of_type('rabbitmq')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of rabbitmq type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      create_from_svc(service_names[0],other_options,&block)
    end

    # Creates and returns an +AMQP+ connection to a rabbitmq service with the
    # specified name.
    # Passes optional other_options and block arguments to +AMQP.connect+.
    # Raises +ArgumentError+ If specified rabbitmq service is not found.
    def self.create_from_svc(service_name, other_options = {}, &block)
      AMQP.connect(options_for_svc(service_name), other_options, &block)
    end

    # Merges provided options with connection options for specified rabbitmq service.
    # Returns merged Hash containing (:user, :pass, :vhost, :host, :port).
    # Raises +ArgumentError+ If specified rabbitmq service is not found.
    def self.options_for_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
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
