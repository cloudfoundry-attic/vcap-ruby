require 'cfruntime/properties'

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
         cfoptions = options
         if !cfoptions[:path].nil?
           #Host and port are ignored if a path is specified
           cfoptions[:path] = "#{service_props[:host]}:#{service_props[:port]}"
         end
         cfoptions[:host] = service_props[:host]
         cfoptions[:port] = service_props[:port]
         cfoptions[:password] = service_props[:password]
         original_initialize cfoptions
       end
     end
   end
end