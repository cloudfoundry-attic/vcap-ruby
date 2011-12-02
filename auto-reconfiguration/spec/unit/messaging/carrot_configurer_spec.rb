require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'carrot'
require 'cfautoconfig/messaging/carrot_configurer'
require 'cfruntime/properties.rb'

describe 'AutoReconfiguration::Carrot' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
    if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
      CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
    end
    #Add access to the opts variable stored on new
    class Carrot
      def opts_for_cf
        @opts
      end
    end
  end

  after(:each) do
    class Carrot
      undef_method :opts_for_cf
    end
  end

  it 'auto-configures Carrot on connect with new format (srs)' do
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.opts_for_cf.should == {  :host => '10.20.30.40', :port =>12345, :user=>'username',
        :pass=>'password', :vhost=>'virtualHost'}
  end

  it 'auto-configures Carrot on connect with old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.opts_for_cf.should == {  :host => '10.20.30.40', :port =>12345, :user=>'username',
        :pass=>'password', :vhost=>'virtualHost'}
  end

  it 'does not auto-configure Carrot if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.opts_for_cf.should == {  :host => '127.0.0.1', :port =>1234, :user=>'testuser',
        :pass=>'testpass', :vhost=>'testvhost'}
  end

  it 'does not open Carrot class to apply methods twice' do
     load 'cfautoconfig/messaging/carrot_configurer.rb'
     #This would blow up massively (stack trace too deep) if we
     #aliased the connect methods twice
     carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
       :pass=>'testpass', :vhost=>'testvhost'})
     carrot.opts_for_cf.should == {  :host => '10.20.30.40', :port =>12345, :user=>'username',
         :pass=>'password', :vhost=>'virtualHost'}
   end

  it 'disables Carrot auto-reconfig if DISABLE_AUTO_CONFIG includes rabbitmq' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:rabbitmq:mongodb"
    load 'cfautoconfig/messaging/carrot_configurer.rb'
    carrot = Carrot.new({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
    carrot.opts_for_cf.should == {  :host => '127.0.0.1', :port =>1234, :user=>'testuser',
        :pass=>'testpass', :vhost=>'testvhost'}
  end
end