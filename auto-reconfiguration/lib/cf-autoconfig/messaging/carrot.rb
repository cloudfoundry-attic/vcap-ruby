require 'cf-runtime/properties'
require 'cf-runtime/carrot'

module AutoReconfiguration
  SUPPORTED_CARROT_VERSION = '1.0'
  module Carrot
    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
    end

    def initialize_with_cf(opts = {})
      service_names = CFRuntime::CloudApp.service_names_of_type('rabbitmq')
      if service_names.length == 1
        puts "Auto-reconfiguring Carrot."
        cfopts = CFRuntime::CarrotClient.options_for_svc(service_names[0],opts)
        original_initialize cfopts
      else
        puts "Found #{service_names.length} rabbitmq services. Skipping auto-reconfiguration."
        original_initialize opts
      end
    end
  end
end
