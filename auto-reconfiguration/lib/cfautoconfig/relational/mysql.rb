require 'cfruntime/properties'

module AutoReconfiguration
  SUPPORTED_MYSQL2_VERSION = '0.2.7'
  module Mysql

    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
    end
     
    def initialize_with_cf(opts = {})
      @service_props = CFRuntime::CloudApp.service_props('mysql')
      if @service_props.nil?
        @auto_config = false
      else
        puts "Auto-reconfiguring MySQL"
        @auto_config = true
      end
      if @auto_config
        original_initialize @service_props
      else
        original_initialize opts    
      end
    end
  end
end



