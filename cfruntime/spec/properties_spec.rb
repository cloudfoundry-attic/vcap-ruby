# Copyright (c) 2009-2011 VMware, Inc.

require File.join(File.dirname(__FILE__), 'spec_helper')
require 'cfruntime/properties.rb'

describe 'CFRuntime::CloudApp' do
  include CFRuntime::Test

  before do
  end

  it 'runs standalone' do
    CFRuntime::CloudApp.running_in_cloud?.should == false
  end

  it 'runs in the cloud' do
    with_vcap_application do
      load 'cfruntime/properties.rb'
      CFRuntime::CloudApp.running_in_cloud?.should == true
    end
  end

  it 'works with a service' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      mongo_svc = CFRuntime::CloudApp.service_props('mongo-test')
      mongo_svc[:name].should == "mongo-test"
    end
  end

  it 'exposes a single service under the name of the service type' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      mongo_svc = CFRuntime::CloudApp.service_props('mongodb')
      mongo_svc[:name].should == "mongo-test"
    end
  end

  it 'works with two services of the same type' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test1'), create_mongo_service('mongo-test2')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      CFRuntime::CloudApp.service_props('mongodb').should == nil
      CFRuntime::CloudApp.service_props('mongo-test1')[:name].should == "mongo-test1"
      CFRuntime::CloudApp.service_props('mongo-test2')[:name].should == "mongo-test2"
    end
  end

  it 'works with services of different types' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')],
      "mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      CFRuntime::CloudApp.service_props('mongodb').should_not == nil
      CFRuntime::CloudApp.service_props('redis').should_not == nil
      CFRuntime::CloudApp.service_props('mongo-test')[:name].should == "mongo-test"
      CFRuntime::CloudApp.service_props('redis-test')[:name].should == "redis-test"
    end
  end

  it 'works with rabbitmq service (old format)' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      CFRuntime::CloudApp.service_props('rabbitmq').should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:name].should == "rabbit-test"
      CFRuntime::CloudApp.service_props('rabbit-test')[:host].should == SOME_SERVER
      CFRuntime::CloudApp.service_props('rabbit-test')[:port].should == 25046
      CFRuntime::CloudApp.service_props('rabbit-test')[:username].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:password].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:vhost].should == "testvhost"
    end
  end

  it 'works with rabbitmq service (new format)' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      CFRuntime::CloudApp.service_props('rabbitmq').should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:name].should == "rabbit-test"
      CFRuntime::CloudApp.service_props('rabbit-test')[:host].should == SOME_SERVER
      CFRuntime::CloudApp.service_props('rabbit-test')[:port].should == 25046
      CFRuntime::CloudApp.service_props('rabbit-test')[:username].should == "rabbituser"
      CFRuntime::CloudApp.service_props('rabbit-test')[:password].should == "rabbitpass"
      CFRuntime::CloudApp.service_props('rabbit-test')[:url].should == "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/testvhost"
      CFRuntime::CloudApp.service_props('rabbit-test')[:vhost].should == "testvhost"
    end
  end

  it 'works with rabbitmq service without vhost (new format)' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      CFRuntime::CloudApp.service_props('rabbitmq').should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:name].should == "rabbit-test"
      CFRuntime::CloudApp.service_props('rabbit-test')[:host].should == SOME_SERVER
      CFRuntime::CloudApp.service_props('rabbit-test')[:port].should == 25046
      CFRuntime::CloudApp.service_props('rabbit-test')[:username].should == "rabbituser"
      CFRuntime::CloudApp.service_props('rabbit-test')[:password].should == "rabbitpass"
      CFRuntime::CloudApp.service_props('rabbit-test')[:url].should == "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}"
      CFRuntime::CloudApp.service_props('rabbit-test')[:vhost].should == '/'
    end
  end

end
