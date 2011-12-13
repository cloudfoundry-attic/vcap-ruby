require 'cfruntime/properties'
require 'cfruntime/carrot'

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
          opts = CFRuntime::CarrotClient.merge_options(opts,service_props)
          original_initialize opts
        end
     end
   end
end