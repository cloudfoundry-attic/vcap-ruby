require 'cf-autoconfig/configuration_helper'
begin
  require 'dalli'
  require File.join(File.dirname(__FILE__), 'dalli')
  memcached_version = Gem.loaded_specs['dalli'].version
  if memcached_version >= Gem::Version.new(AutoReconfiguration::SUPPORTED_DALLI_VERSION)
    if AutoReconfiguration::ConfigurationHelper.disabled? :memcached
      puts "Memcached auto-reconfiguration disabled."
      module Dalli
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
    elsif Dalli::Client.public_instance_methods.index :initialize_with_cf
      #Guard against introducing a method that may already exist
      puts "Memcached auto-reconfiguration already included."
    else
      #Introduce around alias into Memcached class
      module Dalli
        class Client
          include AutoReconfiguration::DalliClient
        end
      end
    end
  else
    puts "Auto-reconfiguration not supported for this Memcached version.  " +
      "Found: #{memcached_version}.  Required: #{AutoReconfiguration::SUPPORTED_DALLI_VERSION} or higher."
  end
rescue LoadError
  puts "No Memcached Library Found. Skipping auto-reconfiguration."
end
