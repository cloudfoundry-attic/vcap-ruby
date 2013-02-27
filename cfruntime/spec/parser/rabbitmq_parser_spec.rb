require 'spec_helper'
require 'cf-runtime/properties'

describe 'CFRuntime::RabbitmqParser' do
  it 'parses a rabbitmq service (old format)' do
    svcs = {
      "rabbitmq-#{rabbit_version}" => [create_rabbit_service('rabbit-test','testvhost')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "rabbitmq",
        :version => "#{rabbit_version}",
        :name => "rabbit-test",
        :username => "rabbituser",
        :password => "rabbitpass",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :vhost => "testvhost",
        :url => "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/testvhost"
      }
      CFRuntime::CloudApp.service_props('rabbitmq').should == expected
    end
  end

  it 'parses a rabbitmq service without vhost (old format)' do
    svcs = {
      "rabbitmq-#{rabbit_version}" => [create_rabbit_service('rabbit-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "rabbitmq",
        :version => "#{rabbit_version}",
        :name => "rabbit-test",
        :username => "rabbituser",
        :password => "rabbitpass",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :vhost => "/",
        :url => "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}"
      }
      CFRuntime::CloudApp.service_props('rabbitmq').should == expected
    end
  end

  it 'parses a rabbitmq service (new format)' do
    svcs = {
      "rabbitmq-#{rabbit_version}" => [create_rabbit_srs_service('rabbit-test','testvhost')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "rabbitmq",
        :version => "#{rabbit_version}",
        :name => "rabbit-test",
        :username => "rabbituser",
        :password => "rabbitpass",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :vhost => "testvhost",
        :url => "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/testvhost"
      }
      CFRuntime::CloudApp.service_props('rabbitmq').should == expected
    end
  end

  it 'parses a rabbitmq service without vhost (new format)' do
    svcs = {
      "rabbitmq-#{rabbit_version}" => [create_rabbit_srs_service('rabbit-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "rabbitmq",
        :version => "#{rabbit_version}",
        :name => "rabbit-test",
        :username => "rabbituser",
        :password => "rabbitpass",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :vhost => "/",
        :url => "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}"
      }
      CFRuntime::CloudApp.service_props('rabbitmq').should == expected
    end
  end
end
