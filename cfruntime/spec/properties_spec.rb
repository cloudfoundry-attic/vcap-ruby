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
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      CFRuntime::CloudApp.running_in_cloud?.should == true
    end
  end

  it 'exposes host and port in the cloud' do
    with_vcap_application do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.host.should == CFRuntime::Test.host
      CFRuntime::CloudApp.port.should == CFRuntime::Test.port
    end
  end

  it 'works with a service' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      mongo_svc = CFRuntime::CloudApp.service_props('mongo-test')
      mongo_svc[:name].should == "mongo-test"
    end
  end

  it 'exposes a single service under the name of the service type' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      mongo_svc = CFRuntime::CloudApp.service_props('mongodb')
      mongo_svc[:name].should == "mongo-test"
    end
  end

  it 'works with two services of the same type' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test1'), create_mongo_service('mongo-test2')]}
    with_vcap_services(svcs) do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
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
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      CFRuntime::CloudApp.service_props('mongodb').should_not == nil
      CFRuntime::CloudApp.service_props('redis').should_not == nil
      CFRuntime::CloudApp.service_props('mongo-test')[:name].should == "mongo-test"
      CFRuntime::CloudApp.service_props('redis-test')[:name].should == "redis-test"
    end
  end

  it 'works with a mongo service and exposes db name' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      mongo_svc = CFRuntime::CloudApp.service_props('mongodb')
      mongo_svc[:db].should == "db"
    end
  end

  it 'works with rabbitmq service (old format)' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
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
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      CFRuntime::CloudApp.service_props('rabbitmq').should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:name].should == "rabbit-test"
      CFRuntime::CloudApp.service_props('rabbit-test')[:host].should == SOME_SERVER
      CFRuntime::CloudApp.service_props('rabbit-test')[:port].should == 25046
      CFRuntime::CloudApp.service_props('rabbit-test')[:username].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:password].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:url].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:vhost].should == "testvhost"
    end
  end

  it 'works with rabbitmq service without vhost (new format)' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test')]}
    with_vcap_services(svcs) do
      if CFRuntime::CloudApp.send(:instance_variable_get, '@svcs')
        CFRuntime::CloudApp.send(:remove_instance_variable, '@svcs')
      end
      CFRuntime::CloudApp.service_props('rabbitmq').should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:name].should == "rabbit-test"
      CFRuntime::CloudApp.service_props('rabbit-test')[:host].should == SOME_SERVER
      CFRuntime::CloudApp.service_props('rabbit-test')[:port].should == 25046
      CFRuntime::CloudApp.service_props('rabbit-test')[:username].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:password].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:url].should_not == nil
      CFRuntime::CloudApp.service_props('rabbit-test')[:vhost].should == '/'
    end
  end

  it 'exposes available service names' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')],
      "mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.service_names.should == ['redis-test', 'mongo-test']
    end
  end

  it 'exposes empty list of services when none defined' do
    with_vcap_services({}) do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.service_names.should == []
    end
  end

  it 'enumerates available service names based on type and empty list if no service is defined' do
    svcs = {
      "redis-#{redis_version}"=>[create_redis_service('redis-test')],
      "mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test'), create_mongo_service('mongo-test2')]}
    with_vcap_services(svcs) do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.service_names_of_type('mongodb').should == ['mongo-test', 'mongo-test2']
      CFRuntime::CloudApp.service_names_of_type('mysql').should == []
    end
  end
end
