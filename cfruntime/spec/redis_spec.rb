require File.join(File.dirname(__FILE__), 'spec_helper')
require 'cfruntime/redis'

describe 'CFRuntime::RedisClient' do
  include CFRuntime::Test

  it 'creates a client with a Redis service by type and no additional options' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')]}
    with_vcap_services(svcs) do
      #TODO remove loads after Thomas' merge
      load 'cfruntime/properties.rb'
      redis = CFRuntime::RedisClient.create
      redis.client.host.should == SOME_SERVER
      redis.client.port.should ==  SOME_SERVICE_PORT
      redis.client.password.should_not == nil
    end
  end

  it 'creates a client with a Redis service by type and additional options' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      redis = CFRuntime::RedisClient.create({:timeout=>1})
      redis.client.host.should == SOME_SERVER
      redis.client.port.should ==  SOME_SERVICE_PORT
      redis.client.password.should_not == nil
      redis.client.timeout.should == 1
    end
  end

  it 'creates a client with a Redis service by name and no additional options' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      redis = CFRuntime::RedisClient.create_from_svc('redis-test')
      redis.client.host.should == SOME_SERVER
      redis.client.port.should ==  SOME_SERVICE_PORT
      redis.client.password.should_not == nil
    end
  end

  it 'creates a client with a Redis service by name and additional options' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      redis = CFRuntime::RedisClient.create_from_svc('redis-test',:timeout=>1)
      redis.client.host.should == SOME_SERVER
      redis.client.port.should ==  SOME_SERVICE_PORT
      redis.client.password.should_not == nil
      redis.client.timeout.should == 1
    end
  end

  it 'raises an ArgumentError if no service of Redis type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::RedisClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if multiple services of Redis type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::RedisClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if Redis service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::RedisClient.create_from_svc('nonexistent-redis')}.to raise_error(ArgumentError,
      'Service with name nonexistent-redis not found')
  end

  it 'merges options with a Redis service with specified path option' do
    service_props = {:host => SOME_SERVER,
                                :port => SOME_SERVICE_PORT,
                                :password => 'testpw'}
    cfopts = CFRuntime::RedisClient.merge_options({:path => '127.0.0.1:6321',
                                :password => 'mypw'}, service_props )
    cfopts.should == {:path => "#{SOME_SERVER}:#{SOME_SERVICE_PORT}",:host => SOME_SERVER,
                                                            :port => SOME_SERVICE_PORT,
                                                            :password => 'testpw'}
  end
end