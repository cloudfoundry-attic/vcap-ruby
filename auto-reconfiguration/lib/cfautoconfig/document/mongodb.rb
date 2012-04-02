require 'cfruntime/properties'

module AutoReconfiguration
  SUPPORTED_MONGO_VERSION = '1.2.0'
  module Mongo

    def self.included( base )
      base.send( :alias_method, :original_initialize, :initialize)
      base.send( :alias_method, :initialize, :initialize_with_cf )
      base.send( :alias_method, :original_apply_saved_authentication, :apply_saved_authentication)
      base.send( :alias_method, :apply_saved_authentication, :apply_saved_authentication_with_cf )
      base.send( :alias_method, :original_db, :db)
      base.send( :alias_method, :db, :db_with_cf )
      base.send( :alias_method, :original_shortcut, :[])
      base.send( :alias_method, :[], :shortcut_with_cf )
    end

    def initialize_with_cf(host = nil, port = nil, opts = {})
      service_names = CFRuntime::CloudApp.service_names_of_type('mongodb')
      if service_names.length == 1
        @service_props = CFRuntime::CloudApp.service_props('mongodb')
        puts "Auto-reconfiguring MongoDB"
        @auto_config = true
        original_initialize @service_props[:host], @service_props[:port], opts
        add_auth(@service_props[:db], @service_props[:username], @service_props[:password])
      else
        puts "Found #{service_names.length} mongo services. Skipping auto-reconfiguration."
        @auto_config = false
        original_initialize host, port, opts
      end
    end

    def apply_saved_authentication_with_cf(opts = {})
      add_auth(@service_props[:db], @service_props[:username], @service_props[:password])
      original_apply_saved_authentication opts
    end

    def db_with_cf(db_name, opts = {})
      if @auto_config && db_name != 'admin'
        add_auth(@service_props[:db], @service_props[:username], @service_props[:password])
        db = original_db @service_props[:db], opts
      else
        original_db db_name, opts
      end
    end

    def shortcut_with_cf(db_name)
      if @auto_config && db_name != 'admin'
        add_auth(@service_props[:db], @service_props[:username], @service_props[:password])
        db = original_shortcut(@service_props[:db])
      else
        db = original_shortcut(db_name)
      end
    end
  end
end
