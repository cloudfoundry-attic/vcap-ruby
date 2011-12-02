require 'cfautoconfig/configuration_helper'
begin
  #Require mongo here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "mongo"
  require File.join(File.dirname(__FILE__), 'mongodb')
  if Gem::Version.new(Mongo::VERSION) >= Gem::Version.new('1.2.0')
    if AutoReconfiguration::ConfigurationHelper.disabled? :mongodb
       puts "MongoDB auto-reconfiguration disabled."
       class Redis
         #Remove introduced aliases and methods.
         #This is mostly for testing, as we don't expect this script
         #to run twice during a single app startup
         if method_defined?(:initialize_with_cf)
           undef_method :initialize_with_cf
           alias :initialize :original_initialize
           undef_method :db_with_cf
           alias :db :original_db
           undef_method :shortcut_with_cf
           alias :[] :original_shortcut
         end
       end
    elsif Mongo::Connection.public_instance_methods.index 'initialize_with_cf'
      puts "MongoDB AutoReconfiguration already included."
    else
      module Mongo
        class Connection
          include AutoReconfiguration::Mongo
        end
      end
    end
  else
    puts "Auto-reconfiguration not supported for this Mongo version."
  end
rescue LoadError
  puts "No MongoDB Library Found. Skipping auto-reconfiguration."
end

