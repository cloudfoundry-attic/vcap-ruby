require 'spec_helper'
require 'cf-runtime/dalli'

describe 'CFRuntime::DalliClient' do

  it 'creates a client with a Memcached service by type and no additional options' do
    svcs = {
      "memcached-#{memcached_version}"=>[create_memcached_service('memcached-test')]}
    with_vcap_services(svcs) do
      memcached = CFRuntime::DalliClient.create
      expected_servers = [ "#{SOME_SERVER}:#{SOME_SERVICE_PORT}" ]
      memcached.instance_variable_get("@servers").should == expected_servers
      options = memcached.instance_variable_get("@options")
      options[:username].should == "testuser"
      options[:password].should == "testpw"
    end
  end

  it 'creates a client with a Memcached service by type and additional options' do
    svcs = {
      "memcached-#{memcached_version}"=>[create_memcached_service('memcached-test')]}
    with_vcap_services(svcs) do
      memcached = CFRuntime::DalliClient.create({:threadsafe=>true})
      expected_servers = [ "#{SOME_SERVER}:#{SOME_SERVICE_PORT}" ]
      memcached.instance_variable_get("@servers").should == expected_servers
      options = memcached.instance_variable_get("@options")
      options[:username].should == "testuser"
      options[:password].should == "testpw"
      options[:threadsafe].should be_true
    end
  end

  it 'creates a client with a Memcached service by name and no additional options' do
    svcs = {
      "memcached-#{memcached_version}"=>[create_memcached_service('memcached-test')]}
    with_vcap_services(svcs) do
      memcached = CFRuntime::DalliClient.create_from_svc('memcached-test')
      expected_servers = [ "#{SOME_SERVER}:#{SOME_SERVICE_PORT}" ]
      memcached.instance_variable_get("@servers").should == expected_servers
      options = memcached.instance_variable_get("@options")
      options[:username].should == "testuser"
      options[:password].should == "testpw"
    end
  end

  it 'creates a client with a Memcached service by name and additional options' do
    svcs = {
      "memcached-#{memcached_version}"=>[create_memcached_service('memcached-test')]}
    with_vcap_services(svcs) do
      memcached = CFRuntime::DalliClient.create_from_svc('memcached-test',:threadsafe=>true)
      expected_servers = [ "#{SOME_SERVER}:#{SOME_SERVICE_PORT}" ]
      memcached.instance_variable_get("@servers").should == expected_servers
      options = memcached.instance_variable_get("@options")
      options[:username].should == "testuser"
      options[:password].should == "testpw"
      options[:threadsafe].should be_true
    end
  end

  it 'raises an ArgumentError if no service of Memcached type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::DalliClient.create}.to raise_error(ArgumentError,
      'Expected 1 service of memcached type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError if multiple services of Memcached type found' do
    svcs = {"memcached-#{memcached_version}"=>[create_memcached_service('memcached-test'),
        create_memcached_service('memcached-test2')]}
    with_vcap_services(svcs) do
      expect{CFRuntime::DalliClient.create}.to raise_error(ArgumentError,
        'Expected 1 service of memcached type, but found 2.  Consider using create_from_svc(service_name) instead.')
    end
  end

  it 'raises an ArgumentError if Memcached service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::DalliClient.create_from_svc('nonexistent-memcached')}.to raise_error(ArgumentError,
      'Service with name nonexistent-memcached not found')
  end
end
