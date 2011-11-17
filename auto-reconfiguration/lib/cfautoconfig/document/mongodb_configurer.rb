require 'cfautoconfig/configuration_helper'
begin
  #Require mongo here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "mongo"
  require File.join(File.dirname(__FILE__), 'mongodb')

  #TODO supported version check
  if AutoReconfiguration::ConfigurationHelper.disabled? :mongodb
     #TODO undo introduced methods (for testing)
     puts "MongoDB auto-reconfiguration disabled."
  elsif Mongo::Connection.public_instance_methods.index 'initialize_with_cf'
    puts "MongoDB AutoReconfiguration already included!!!!"
  else
    module Mongo
      class Connection
        include AutoReconfiguration::Mongo
      end
    end
  end

rescue LoadError
  puts "No MongoDB Library Found. Skipping auto-reconfiguration."
end

