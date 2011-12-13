require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'redis'
require 'cfautoconfig/keyvalue/redis_configurer'
require 'cfruntime/properties.rb'

describe 'AutoReconfiguration::Redis' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"redis-2.2":[{"name": "redis-1","label": "redis-2.2",' +
      '"plan": "free", "credentials": {"node_id": "redis_node_8","hostname": ' +
      '"10.20.30.40","port": 1234,"password": "mypass","name": "r1"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
  end

  it 'auto-configures Redis on initialize with host and port' do
    redis = Redis.new(:host => '127.0.0.1',
                                :port => '6321',
                                :password => 'mypw')
    redis.client.host.should == '10.20.30.40'
    redis.client.port.should ==  1234
    redis.client.password.should == 'mypass'
  end

  it 'auto-configures Redis on initialize with path' do
    redis = Redis.new(:path => '127.0.0.1:6321',
                                :password => 'mypw')
    redis.client.host.should == '10.20.30.40'
    redis.client.port.should ==  1234
    redis.client.path.should == nil
    redis.client.password.should == 'mypass'
  end

  it 'does not auto-configure Redis if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    redis = Redis.new(:host => '127.0.0.1',
                                 :port => '6321',
                                 :password => 'mypw')
    redis.client.host.should == '127.0.0.1'
    redis.client.port.should ==  6321
    redis.client.password.should == 'mypw'
  end

  it 'does not auto-configure Redis if multiple Redis services found' do
    ENV['VCAP_SERVICES'] = '{"redis-2.2":[{"name": "redis-1","label": "redis-2.2",' +
      '"plan": "free", "credentials": {"node_id": "redis_node_8","hostname": ' +
      '"10.20.30.40","port": 1234,"password": "mypass","name": "r1"}},' +
      '{"name": "redis-2","label": "redis-2.2",' +
      '"plan": "free", "credentials": {"node_id": "redis_node_8","hostname": ' +
      '"10.20.30.40","port": 1234,"password": "mypass","name": "r1"}}]}'
    redis = Redis.new(:host => '127.0.0.1',
                                 :port => '6321',
                                 :password => 'mypw')
    redis.client.host.should == '127.0.0.1'
    redis.client.port.should ==  6321
    redis.client.password.should == 'mypw'
  end

  it 'does not open Redis class to apply methods twice' do
    load 'cfautoconfig/keyvalue/redis_configurer.rb'
    #This would blow up massively (stack trace too deep) if we
    #aliased initialize twice
    redis = Redis.new(:host => '127.0.0.1',
                                   :port => '6321',
                                   :password => 'mypw')
    redis.client.host.should == '10.20.30.40'
    redis.client.port.should ==  1234
    redis.client.password.should == 'mypass'
   end

  it 'disables Redis auto-reconfig if DISABLE_AUTO_CONFIG includes redis' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:mongodb"
    load 'cfautoconfig/keyvalue/redis_configurer.rb'
    redis = Redis.new(:host => '127.0.0.1',
                                :port => '6321',
                                :password => 'mypw')
    redis.client.host.should == '127.0.0.1'
    redis.client.port.should ==  6321
    redis.client.password.should == 'mypw'
  end
end