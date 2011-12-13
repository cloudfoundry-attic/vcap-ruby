require 'cfruntime/properties'
require 'cfruntime/amqp'

module AutoReconfiguration
  SUPPORTED_AMQP_VERSION = '0.8'
  module AMQP
    def self.included( base )
      base.send( :alias_method, :original_connect, :connect)
      base.send( :alias_method, :connect, :connect_with_cf )
    end

    def connect_with_cf(connection_options_or_string = {}, other_options = {}, &block)
      service_names = CFRuntime::CloudApp.service_names_of_type('rabbitmq')
      if service_names.length == 1
        puts "Auto-reconfiguring AMQP."
        case connection_options_or_string
          when String then
            cfoptions = {}
          else
            cfoptions = connection_options_or_string
          end
        original_connect(CFRuntime::AMQPClient.options_for_svc(service_names[0],cfoptions),
          other_options, &block)
      else
        puts "Found #{service_names.length} rabbitmq services. Skipping auto-reconfiguration."
        original_connect(connection_options_or_string, other_options, &block)
      end
    end
  end
end