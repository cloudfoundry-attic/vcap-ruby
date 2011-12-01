require 'cfautoconfig/configuration_helper'
SUPPORTED_CARROT_VERSION = '1.0'
begin
  #Require carrot here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "carrot"
  require File.join(File.dirname(__FILE__), 'carrot')
  carrot_version = Gem.loaded_specs['carrot'].version
  if carrot_version >= Gem::Version.new(SUPPORTED_CARROT_VERSION)
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
    puts "Auto-reconfiguration not supported for this Carrot version.  " +
      "Found: #{carrot_version}.  Required: #{SUPPORTED_CARROT_VERSION} or higher."
  end
rescue LoadError
  puts "No Carrot Library Found. Skipping auto-reconfiguration."
end