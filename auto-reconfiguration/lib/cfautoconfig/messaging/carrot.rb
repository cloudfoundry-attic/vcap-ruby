require 'cfruntime/properties'

module AutoReconfiguration
   module Carrot
     def self.included( base )
       base.send( :alias_method, :original_initialize, :initialize)
       base.send( :alias_method, :initialize, :initialize_with_cf )
     end

     def initialize_with_cf(opts = {})
       service_props = CFRuntime::CloudApp.service_props('rabbitmq')
        if(service_props.nil?)
          puts "No RabbitMQ service bound to app.  Skipping auto-reconfiguration."
          original_initialize opts
        else
          puts "Auto-reconfiguring Carrot."
          cfoptions = opts
          cfoptions[:host] = service_props[:host]
          cfoptions[:port] = service_props[:port]
          cfoptions[:user] = service_props[:username]
          cfoptions[:pass] = service_props[:password]
          cfoptions[:vhost] = service_props[:vhost]
          original_initialize opts
        end
     end
   end
end