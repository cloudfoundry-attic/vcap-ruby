require 'cfruntime/properties'
require 'cfruntime/mysql'

module AutoReconfiguration
  module Mysql

    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
    end
     
    def initialize_with_cf(opts = {})
      service_names = CFRuntime::CloudApp.service_names_of_type('mysql')
      if service_names.length == 1
        puts "Auto-reconfiguring MySQL"
        original_initialize(CFRuntime::Mysql2Client.options_for_svc(service_names[0],opts))
      else
        puts "Found #{service_names.length} mysql services. Skipping auto-reconfiguration."
        original_initialize opts
      end
    end
  end
end



