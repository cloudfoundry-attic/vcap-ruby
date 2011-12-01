require 'spec_helper'
require 'amqp'
require 'cfautoconfig/messaging/amqp_configurer'

describe 'AutoReconfiguration::AMQP' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
    load 'cfruntime/properties.rb'
  end

  it 'auto-configures AMQP on connect with options and new format (srs)' do
    conn_error = attempt_amqp_connect({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    conn_error.should =~ /Could not estabilish TCP connection to 10.20.30.40:12345/
  end

  it 'auto-configures AMQP on connect with options and old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    load 'cfruntime/properties.rb'
    conn_error = attempt_amqp_connect ({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    conn_error.should =~ /Could not estabilish TCP connection to 10.20.30.40:12345/
  end

  it 'auto-configures AMQP on connect with url and new format (srs)' do
    conn_error = attempt_amqp_connect "amqp://testuser:testpass@127.0.0.1:1234/testvhost"
    conn_error.should =~ /Could not estabilish TCP connection to 10.20.30.40:12345/
  end

  it 'auto-configures AMQP on connect with url and old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    load 'cfruntime/properties.rb'
    conn_error = attempt_amqp_connect "amqp://testuser:testpass@127.0.0.1:1234/testvhost"
    conn_error.should =~ /Could not estabilish TCP connection to 10.20.30.40:12345/
  end

  it 'does not auto-configure AMQP if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    conn_error = attempt_amqp_connect "amqp://testuser:testpass@127.0.0.1:1234/testvhost"
    conn_error.should =~ /Could not estabilish TCP connection to 127.0.0.1:1234/
  end

  it 'does not open AMQP class to apply methods twice' do
     load 'cfautoconfig/messaging/amqp_configurer.rb'
     #This would blow up massively (stack trace too deep) if we
     #aliased the connect methods twice
     conn_error = attempt_amqp_connect "amqp://testuser:testpass@127.0.0.1:1234/testvhost"
     conn_error.should =~ /Could not estabilish TCP connection to 10.20.30.40:12345/
   end

  it 'disables AMQP auto-reconfig if DISABLE_AUTO_CONFIG includes rabbitmq' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:rabbitmq:mongodb"
    load 'cfautoconfig/messaging/amqp_configurer.rb'
    conn_error = attempt_amqp_connect "amqp://testuser:testpass@127.0.0.1:1234/testvhost"
    conn_error.should =~ /Could not estabilish TCP connection to 127.0.0.1:1234/
  end

end

private
def attempt_amqp_connect(connection_options_or_string)
  conn_error = ''
  begin
    EventMachine.run do
      connection = AMQP.connect(connection_options_or_string, :timeout=> 1)
    end
  rescue Exception=>e
    conn_error = e.message
  end
  conn_error
end
