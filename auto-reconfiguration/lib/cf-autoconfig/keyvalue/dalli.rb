require 'cf-runtime/properties'
require 'cf-runtime/dalli'

module AutoReconfiguration
  SUPPORTED_DALLI_VERSION = '2.6.4'
  module DalliClient
    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
    end

    def initialize_with_cf(servers, options = {})
      service_names = CFRuntime::CloudApp.service_names_of_type('memcached')
      if service_names.length == 1
        puts "Auto-reconfiguring Memcached."
        cfoptions = CFRuntime::DalliClient.options_for_svc(service_names[0],options)
        original_initialize *cfoptions
      else
        puts "Found #{service_names.length} memcached services. Skipping auto-reconfiguration."
        original_initialize servers, options
      end
    end
  end
end
