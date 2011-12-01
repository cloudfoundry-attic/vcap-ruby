require 'spec_helper'
require 'carrot'
require 'cfautoconfig/messaging/carrot_configurer'

describe 'AutoReconfiguration::Carrot' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
    load 'cfruntime/properties.rb'
  end

  it 'auto-configures Carrot on connect with new format (srs)' do
    conn_error = attempt_connect ({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    conn_error.should == 'execution expired - 10.20.30.40:12345'
  end

  it 'auto-configures Carrot on connect with old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    load 'cfruntime/properties.rb'
    conn_error = attempt_connect ({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    conn_error.should == 'execution expired - 10.20.30.40:12345'
  end

  it 'does not auto-configure Carrot if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    conn_error = attempt_connect ({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    conn_error.should == 'Connection refused - connect(2) - 127.0.0.1:1234'
  end

  it 'does not open Carrot class to apply methods twice' do
     load 'cfautoconfig/messaging/carrot_configurer.rb'
     #This would blow up massively (stack trace too deep) if we
     #aliased the connect methods twice
     conn_error = attempt_connect ({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
       :pass=>'testpass', :vhost=>'testvhost'})
     conn_error.should == 'execution expired - 10.20.30.40:12345'
   end

  it 'disables Carrot auto-reconfig if DISABLE_AUTO_CONFIG includes rabbitmq' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:rabbitmq:mongodb"
    load 'cfautoconfig/messaging/carrot_configurer.rb'
    conn_error = attempt_connect ({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    conn_error.should == 'Connection refused - connect(2) - 127.0.0.1:1234'
  end
end

private
def attempt_connect(opts)
  conn_error = ''
  begin
    carrot = Carrot.new(opts)
    carrot.server
  rescue Exception=>e
    conn_error = e.message
  end
  conn_error
end
