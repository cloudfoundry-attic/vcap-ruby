require 'cfautoconfig/configuration_helper'
begin
  #Require pg here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "pg"
  require File.join(File.dirname(__FILE__), 'postgres')
  if Gem::Version.new(PGconn::VERSION) >= Gem::Version.new(AutoReconfiguration::SUPPORTED_PG_VERSION)
    if AutoReconfiguration::ConfigurationHelper.disabled? :postgresql
      puts "PostgreSQL auto-reconfiguration disabled."
      class << PGconn
        #Remove introduced aliases and methods.
        #This is mostly for testing, as we don't expect this script
        #to run twice during a single app startup
        if method_defined?(:open_with_cf)
          undef_method :open_with_cf
          alias :open :original_open
        end
        if method_defined?(:connect_with_cf)
          undef_method :connect_with_cf
          alias :connect :original_connect
        end
        if method_defined?(:connect_start_with_cf)
          undef_method :connect_start_with_cf
          alias :connect_start :original_connect_start
        end
      end
    elsif PGconn.public_methods.index :open_with_cf
      puts "PostgreSQL AutoReconfiguration already included."
    else
      #Introduce around alias into PGconn class
      class << PGconn
        include AutoReconfiguration::Postgres
       end
    end
  else
    puts "Auto-reconfiguration not supported for this PG version.  " +
      "Found: #{PGconn::VERSION}.  Required: #{AutoReconfiguration::SUPPORTED_PG_VERSION} or higher."
  end
rescue LoadError
  puts "No PostgreSQL Library Found. Skipping auto-reconfiguration."
end

