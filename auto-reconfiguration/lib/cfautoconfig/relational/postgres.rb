require 'cfruntime/properties'
module AutoReconfiguration
  module Postgres
    def self.included( base )
      base.send( :alias_method, :original_open, :open)
      base.send( :alias_method, :open, :open_with_cf )
      base.send( :alias_method, :original_connect, :connect)
      base.send( :alias_method, :connect, :connect_with_cf )
      base.send( :alias_method, :original_connect_start, :connect_start)
      base.send( :alias_method, :connect_start, :connect_start_with_cf )
    end

    def open_with_cf(*args,&block)
      connection_string = parse_cf_connection_args(*args,&block)
      original_open(connection_string)
    end

    def connect_with_cf(*args,&block)
      connection_string = parse_cf_connection_args(*args,&block)
      original_connect(connection_string)
    end

    def connect_start_with_cf(*args,&block)
      connection_string = parse_cf_connection_args(*args,&block)
      original_connect_start(connection_string)
    end

    private
    # Parses all possible argument formats and returns a single connection string
    # that includes all necessary connection parameters for the CF Postgres service
    # Possible argument formats:
    # ()
    # (connection_hash)
    # (connection_string)
    # (host, port, options, tty, dbname, user, password)
    def parse_cf_connection_args(*args,&block)
      service_props = CFRuntime::CloudApp.service_props('postgresql')
      if(service_props.nil?)
        puts "No PostgreSQL service bound to app.  Skipping auto-reconfiguration."
        return args
      end
      puts "Auto-reconfiguring PostgreSQL."
      #Use the parse_connect_args method from pg to process all possible formats into a single connection string
      conn_string= parse_connect_args(*args)
      sub_or_append_cf_arg(conn_string,'dbname',service_props[:database])
      sub_or_append_cf_arg(conn_string,'host',service_props[:host])
      sub_or_append_cf_arg(conn_string,'port',service_props[:port])
      sub_or_append_cf_arg(conn_string,'user',service_props[:username])
      sub_or_append_cf_arg(conn_string,'password',service_props[:password])

      #Send the new connection string to passed block for verification.
      #Block should only be passed by tests.  User code never sends a block.
      #This is done b/c Postgres conn timeout Exception msg doesn't tell you
      #what server it is trying to connect to
      if(block)
        block.yield(conn_string)
      end
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



