require 'cf-runtime/properties'
module AutoReconfiguration
  SUPPORTED_PG_VERSION = '0.11.0'
  module Postgres
    def self.included( base )
      base.send( :alias_method, :original_open, :open)
      base.send( :alias_method, :open, :open_with_cf )
      base.send( :alias_method, :original_connect, :connect)
      base.send( :alias_method, :connect, :connect_with_cf )
      base.send( :alias_method, :original_connect_start, :connect_start)
      base.send( :alias_method, :connect_start, :connect_start_with_cf )
    end

    def open_with_cf(*args)
      connection_string = parse_cf_connection_args(*args)
      if connection_string
        #Send the new connection string to passed block for verification.
        yield connection_string if block_given?
        original_open(connection_string)
      else
        original_open(*args)
      end
    end

    def connect_with_cf(*args)
      connection_string = parse_cf_connection_args(*args)
      if connection_string
        #Send the new connection string to passed block for verification.
        yield connection_string if block_given?
        original_connect(connection_string)
      else
        original_connect(*args)
      end
    end

    def connect_start_with_cf(*args)
      connection_string = parse_cf_connection_args(*args)
      if connection_string
        #Send the new connection string to passed block for verification.
        yield connection_string if block_given?
        original_connect_start(connection_string)
      else
        original_connect_start(*args)
      end
    end

    private
    # Parses all possible argument formats and returns a single connection string
    # that includes all necessary connection parameters for the CF Postgres service
    # Possible argument formats:
    # ()
    # (connection_hash)
    # (connection_string)
    # (host, port, options, tty, dbname, user, password)
    def parse_cf_connection_args(*args)
      service_names = CFRuntime::CloudApp.service_names_of_type('postgresql')
      if service_names.length != 1
        puts "Found #{service_names.length} postgresql services. Skipping auto-reconfiguration."
        return
      end
      puts "Auto-reconfiguring PostgreSQL."
      service_props = CFRuntime::CloudApp.service_props('postgresql')
      #Use the parse_connect_args method from pg to process all possible formats into a single connection string
      conn_string= parse_connect_args(*args)
      sub_or_append_cf_arg(conn_string,'dbname',service_props[:database])
      sub_or_append_cf_arg(conn_string,'host',service_props[:host])
      sub_or_append_cf_arg(conn_string,'port',service_props[:port])
      sub_or_append_cf_arg(conn_string,'user',service_props[:username])
      sub_or_append_cf_arg(conn_string,'password',service_props[:password])
      conn_string
    end

    def sub_or_append_cf_arg(conn_string,key,value)
      cf_conn_string = conn_string.gsub!(/#{key}=\S+/,"#{key}='#{value}'")
      if(cf_conn_string.nil?)
        conn_string << " #{key}='#{value}'"
      end
    end
  end
end
