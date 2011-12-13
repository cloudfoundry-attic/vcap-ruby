require 'cfruntime/properties'
require 'cfruntime/redis'

module AutoReconfiguration
   module Redis
     def self.included( base )
       base.send( :alias_method, :original_initialize, :initialize)
       base.send( :alias_method, :initialize, :initialize_with_cf )
     end

     def initialize_with_cf(options = {})
       service_props = CFRuntime::CloudApp.service_props('redis')
       if(service_props.nil?)
         puts "No Redis service bound to app.  Skipping auto-reconfiguration."
         original_initialize options
       else
         puts "Auto-reconfiguring Redis."
         cfoptions = CFRuntime::RedisClient.merge_options(options,service_props)
         original_initialize cfoptions
       end
     end
   end
end