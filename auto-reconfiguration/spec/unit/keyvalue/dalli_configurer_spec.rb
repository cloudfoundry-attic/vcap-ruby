require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'dalli'
require 'cf-autoconfig/keyvalue/dalli_configurer'
require 'cf-runtime/properties.rb'

describe 'AutoReconfiguration::Dalli' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"memcached-1.4":[{"name":"memcached-1","label":"memcached-1.4",' +
      '"plan":"100","credentials":{"name":"r1","hostname":"10.20.30.40","host":"10.20.30.40",' +
      '"port":1234,"user":"testuser","password":"testpw"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
  end

  it 'auto-configures Memcached on initialize with host and port' do
    memcached = Dalli::Client.new('127.0.0.1:6321',
                                :username => 'harduser',
                                :password => 'hardpass')
    memcached.instance_variable_get("@servers").should == [ '10.20.30.40:1234' ]
    options = memcached.instance_variable_get("@options")
    options[:username].should == "testuser"
    options[:password].should == "testpw"
  end

  it 'auto-configures Memcached on initialize with additional options' do
    memcached = Dalli::Client.new('127.0.0.1:6321',
                                :username => 'harduser',
                                :password => 'hardpass',
                                :threadsave => true)
    memcached.instance_variable_get("@servers").should == [ '10.20.30.40:1234' ]
    options = memcached.instance_variable_get("@options")
    options[:username].should == "testuser"
    options[:password].should == "testpw"
    options[:threadsave].should be_true
  end

  it 'does not auto-configure Memcached if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    memcached = Dalli::Client.new('127.0.0.1:6321',
                                :username => 'harduser',
                                :password => 'hardpass')
    memcached.instance_variable_get("@servers").should == [ '127.0.0.1:6321' ]
    options = memcached.instance_variable_get("@options")
    options[:username].should == "harduser"
    options[:password].should == "hardpass"
  end

  it 'does not auto-configure Memcached if multiple Memcached services found' do
    ENV['VCAP_SERVICES'] = '{"memcached-1.4":[{"name":"memcached-1","label":"memcached-1.4",' +
      '"plan":"100","credentials":{"name":"r1","hostname":"10.20.30.40","host":"10.20.30.40",' +
      '"port":1234,"user":"testuser1","password":"testpw2"}},' +
      '{"name":"memcached-2","label":"memcached-1.4",' +
      '"plan":"100","credentials":{"name":"r2","hostname":"10.20.30.40","host":"10.20.30.40",' +
      '"port":5467,"user":"testuser2","password":"testpw2"}} ]}'
    memcached = Dalli::Client.new('127.0.0.1:6321',
                                :username => 'harduser',
                                :password => 'hardpass')
    memcached.instance_variable_get("@servers").should == [ '127.0.0.1:6321' ]
    options = memcached.instance_variable_get("@options")
    options[:username].should == "harduser"
    options[:password].should == "hardpass"
  end

  it 'does not open Memcached class to apply methods twice' do
    load 'cf-autoconfig/keyvalue/dalli_configurer.rb'
    #This would blow up massively (stack trace too deep) if we
    #aliased initialize twice
    memcached = Dalli::Client.new('127.0.0.1:6321',
                                :username => 'harduser',
                                :password => 'hardpass')
    memcached.instance_variable_get("@servers").should == [ '10.20.30.40:1234' ]
    options = memcached.instance_variable_get("@options")
    options[:username].should == "testuser"
    options[:password].should == "testpw"
   end

  it 'disables Memcached auto-reconfig if DISABLE_AUTO_CONFIG includes memcached' do
    ENV['DISABLE_AUTO_CONFIG'] = "memcached:mongodb"
    load 'cf-autoconfig/keyvalue/dalli_configurer.rb'
    memcached = Dalli::Client.new('127.0.0.1:6321',
                                :username => 'harduser',
                                :password => 'hardpass')
    memcached.instance_variable_get("@servers").should == [ '127.0.0.1:6321' ]
    options = memcached.instance_variable_get("@options")
    options[:username].should == "harduser"
    options[:password].should == "hardpass"
  end
end
