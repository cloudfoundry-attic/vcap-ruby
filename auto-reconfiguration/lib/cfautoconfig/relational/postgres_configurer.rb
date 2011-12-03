require 'cfautoconfig/configuration_helper'
SUPPORTED_PG_VERSION = '0.11.0'
begin
  #Require pg here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "pg"
  require File.join(File.dirname(__FILE__), 'postgres')
  if Gem::Version.new(PGconn::VERSION) >= Gem::Version.new(SUPPORTED_PG_VERSION)
    if AutoReconfiguration::ConfigurationHelper.disabled? :postgresql
      puts "PostgreSQL auto-reconfiguration disabled."
      #Remove introduced aliases and methods.
      #This is mostly for testing, as we don't expect this script
      #to run twice during a single app startup
      class << PGconn
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
      puts "PostgreSQL AutoReconfiguration already included!!!!"
    else
      class << PGconn
        include AutoReconfiguration::Postgres
       end
    end
  else
    puts "Auto-reconfiguration not supported for this PG version.  " +
      "Found: #{PGconn::VERSION}.  Required: #{SUPPORTED_PG_VERSION} or higher."
  end
rescue LoadError
  puts "No PostgreSQL Library Found. Skipping auto-reconfiguration."
end

