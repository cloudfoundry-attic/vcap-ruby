require 'cf-runtime/properties'
require 'cf-runtime/redis'

module AutoReconfiguration
  SUPPORTED_REDIS_VERSION = '2.0'
  module Redis
    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
    end

    def initialize_with_cf(options = {})
      service_names = CFRuntime::CloudApp.service_names_of_type('redis')
      if service_names.length == 1
        puts "Auto-reconfiguring Redis."
        cfoptions = CFRuntime::RedisClient.options_for_svc(service_names[0],options)
        original_initialize cfoptions
      else
        puts "Found #{service_names.length} redis services. Skipping auto-reconfiguration."
        original_initialize options
      end
    end
  end
end
