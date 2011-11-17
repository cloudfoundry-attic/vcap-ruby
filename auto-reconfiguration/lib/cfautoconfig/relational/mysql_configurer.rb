require 'cfautoconfig/configuration_helper'
begin
  #Require mysql2 here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "mysql2"
  require File.join(File.dirname(__FILE__), 'mysql')

  #TODO supported version check
  if AutoReconfiguration::ConfigurationHelper.disabled? :mysql
    #TODO undo introduced methods (for testing)
    puts "MySQL auto-reconfiguration disabled."
  elsif Mysql2::Client.public_instance_methods.index 'initialize_with_cf'
    puts "MySQL AutoReconfiguration already included!!!!"
  else
    module Mysql2
      class Client
        include AutoReconfiguration::Mysql
      end
    end
  end

rescue LoadError
  puts "No MySQL Library Found. Skipping auto-reconfiguration."
end

