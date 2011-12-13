require 'cfautoconfig/configuration_helper'
begin
  #Require amqp here is mandatory for configurer to ensure class is loaded before applying OpenClass
  require "amqp"
  require File.join(File.dirname(__FILE__), 'amqp')
  if Gem::Version.new(AMQP::VERSION) >= Gem::Version.new(AutoReconfiguration::SUPPORTED_AMQP_VERSION)
    if AutoReconfiguration::ConfigurationHelper.disabled? :rabbitmq
      puts "RabbitMQ auto-reconfiguration disabled."
      class << AMQP
        #Remove introduced aliases and methods.
        #This is mostly for testing, as we don't expect this script
        #to run twice during a single app startup
        if method_defined?(:connect_with_cf)
          undef_method :connect_with_cf
          alias :connect :original_connect
        end
      end
    elsif AMQP.public_methods.index :connect_with_cf
      puts "AMQP AutoReconfiguration already included."
    else
      #Introduce around alias into AMQP class
      class << AMQP
        include AutoReconfiguration::AMQP
       end
    end
  else
    puts "Auto-reconfiguration not supported for this AMQP version.  " +
      "Found: #{AMQP::VERSION}.  Required: #{AutoReconfiguration::SUPPORTED_AMQP_VERSION} or higher."
  end
rescue LoadError
  puts "No AMQP Library Found. Skipping auto-reconfiguration."
end