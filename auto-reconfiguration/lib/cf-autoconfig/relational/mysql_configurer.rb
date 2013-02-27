require 'cf-autoconfig/configuration_helper'

begin
  #Require mysql2 here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "mysql2"
  require File.join(File.dirname(__FILE__), 'mysql')
  mysql2_version = Gem.loaded_specs['mysql2'].version
  if mysql2_version >= Gem::Version.new(AutoReconfiguration::SUPPORTED_MYSQL2_VERSION)
    if AutoReconfiguration::ConfigurationHelper.disabled? :mysql
      puts "MySQL auto-reconfiguration disabled."
      module Mysql2
        class Client
          #Remove introduced aliases and methods.
          #This is mostly for testing, as we don't expect this script
          #to run twice during a single app startup
          if method_defined?(:initialize_with_cf)
            undef_method :initialize_with_cf
            alias :initialize :original_initialize
          end
        end
      end
    elsif Mysql2::Client.public_instance_methods.index 'initialize_with_cf'
      puts "MySQL AutoReconfiguration already included."
    else
      module Mysql2
        class Client
          include AutoReconfiguration::Mysql
        end
      end
    end
  else
    puts "Auto-reconfiguration not supported for this Mysql2 version.  " +
      "Found: #{mysql2_version}.  Required: #{AutoReconfiguration::SUPPORTED_MYSQL2_VERSION} or higher."
  end
rescue LoadError
  puts "No MySQL Library Found. Skipping auto-reconfiguration."
end

