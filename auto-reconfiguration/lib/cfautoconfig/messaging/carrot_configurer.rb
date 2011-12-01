require 'cfautoconfig/configuration_helper'
begin
  #Require carrot here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "carrot"
  require File.join(File.dirname(__FILE__), 'carrot')
  if Gem.loaded_specs['carrot'].version >= Gem::Version.new('1.0')
    if AutoReconfiguration::ConfigurationHelper.disabled? :rabbitmq
      puts "RabbitMQ auto-reconfiguration disabled."
      class Carrot
        #Remove introduced aliases and methods.
        #This is mostly for testing, as we don't expect this script
        #to run twice during a single app startup
        if method_defined?(:initialize_with_cf)
          undef_method :initialize_with_cf
          alias :initialize :original_initialize
        end
      end
    elsif Carrot.public_instance_methods.index :initialize_with_cf
      puts "Carrot AutoReconfiguration already included."
    else
      class Carrot
        include AutoReconfiguration::Carrot
       end
    end
  else
    puts "Auto-reconfiguration not supported for this Carrot version."
  end
rescue LoadError
  puts "No Carrot Library Found. Skipping auto-reconfiguration."
end