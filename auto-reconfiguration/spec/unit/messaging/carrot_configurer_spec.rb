require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'carrot'
require 'cf-autoconfig/messaging/carrot_configurer'
require 'cf-runtime/properties.rb'

describe 'AutoReconfiguration::Carrot' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
  end

  it 'auto-configures Carrot on connect with new format (srs)' do
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.instance_variable_get("@opts").should == {  :host => '10.20.30.40', :port =>12345, :user=>'username',
        :pass=>'password', :vhost=>'virtualHost'}
  end

  it 'auto-configures Carrot on connect with old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.instance_variable_get("@opts").should == {  :host => '10.20.30.40', :port =>12345, :user=>'username',
        :pass=>'password', :vhost=>'virtualHost'}
  end

  it 'does not auto-configure Carrot if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.instance_variable_get("@opts").should == {  :host => '127.0.0.1', :port =>1234, :user=>'testuser',
        :pass=>'testpass', :vhost=>'testvhost'}
  end

  it 'does not auto-configure Carrot if multiple Rabbit services found' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}},' +
      '{"name": "rabbit-2","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}}]}'
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.instance_variable_get("@opts").should == {  :host => '127.0.0.1', :port =>1234, :user=>'testuser',
        :pass=>'testpass', :vhost=>'testvhost'}
  end

  it 'does not open Carrot class to apply methods twice' do
     load 'cf-autoconfig/messaging/carrot_configurer.rb'
     #This would blow up massively (stack trace too deep) if we
     #aliased the connect methods twice
     carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
       :pass=>'testpass', :vhost=>'testvhost'})
     carrot.instance_variable_get("@opts").should == {  :host => '10.20.30.40', :port =>12345, :user=>'username',
         :pass=>'password', :vhost=>'virtualHost'}
   end

  it 'disables Carrot auto-reconfig if DISABLE_AUTO_CONFIG includes rabbitmq' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:rabbitmq:mongodb"
    load 'cf-autoconfig/messaging/carrot_configurer.rb'
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.instance_variable_get("@opts").should == {  :host => '127.0.0.1', :port =>1234, :user=>'testuser',
        :pass=>'testpass', :vhost=>'testvhost'}
  end
end
