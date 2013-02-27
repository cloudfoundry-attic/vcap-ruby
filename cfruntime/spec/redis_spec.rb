require 'spec_helper'
require 'cf-runtime/redis'

describe 'CFRuntime::RedisClient' do

  it 'creates a client with a Redis service by type and no additional options' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')]}
    with_vcap_services(svcs) do
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
      redis = CFRuntime::RedisClient.create_from_svc('redis-test',:timeout=>1)
      redis.client.host.should == SOME_SERVER
      redis.client.port.should ==  SOME_SERVICE_PORT
      redis.client.password.should_not == nil
      redis.client.timeout.should == 1
    end
  end

  it 'raises an ArgumentError if no service of Redis type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::RedisClient.create}.to raise_error(ArgumentError,
      'Expected 1 service of redis type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError if multiple services of Redis type found' do
    svcs = {"redis-#{redis_version}"=>[create_redis_service('redis-test'),
        create_redis_service('redis-test2')]}
    with_vcap_services(svcs) do
      expect{CFRuntime::RedisClient.create}.to raise_error(ArgumentError,
        'Expected 1 service of redis type, but found 2.  Consider using create_from_svc(service_name) instead.')
    end
  end

  it 'raises an ArgumentError if Redis service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::RedisClient.create_from_svc('nonexistent-redis')}.to raise_error(ArgumentError,
      'Service with name nonexistent-redis not found')
  end
end
