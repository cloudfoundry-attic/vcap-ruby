require 'cfruntime/properties'
require 'cfruntime/mysql'

module AutoReconfiguration
  module Mysql

    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
    end
     
    def initialize_with_cf(opts = {})
      service_props = CFRuntime::CloudApp.service_props('mysql')
      if service_props.nil?
        puts "No MySQL service bound to app.  Skipping auto-reconfiguration."
        original_initialize opts
      else
        puts "Auto-reconfiguring MySQL"
        original_initialize(CFRuntime::Mysql2Client.merge_options(opts,service_props))
      end
    end
  end
end



