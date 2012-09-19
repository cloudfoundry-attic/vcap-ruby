require 'spec_helper'
require 'cfruntime/carrot'

describe 'CFRuntime::CarrotClient' do

  it 'creates a client with a Rabbit service by type and no additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      carrot = CFRuntime::CarrotClient.create
      carrot.instance_variable_get("@opts").should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost'}
    end
  end

  it 'creates a client with a Rabbit service by type and additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    opts = {:some=>'thing'}
    with_vcap_services(svcs) do
      carrot = CFRuntime::CarrotClient.create(opts)
      carrot.instance_variable_get("@opts").should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost', :some=>'thing'}
    end
  end

  it 'creates a client with a Rabbit service by name and no additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      carrot = CFRuntime::CarrotClient.create_from_svc('rabbit-test')
      carrot.instance_variable_get("@opts").should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost'}
    end
  end

  it 'creates a client with a Rabbit service by name and additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    opts = {:some=>'thing'}
    with_vcap_services(svcs) do
      carrot = CFRuntime::CarrotClient.create_from_svc('rabbit-test',opts)
      carrot.instance_variable_get("@opts").should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost', :some=>'thing'}
    end
  end

  it 'raises an ArgumentError if no service of Rabbit type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::CarrotClient.create}.to raise_error(ArgumentError,
      'Expected 1 service of rabbitmq type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError if multiple services of Rabbit type found' do
     svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost'),
        create_rabbit_srs_service('rabbit-test2','testvhost')]}
      with_vcap_services(svcs) do
        expect{CFRuntime::CarrotClient.create}.to raise_error(ArgumentError,
          'Expected 1 service of rabbitmq type, but found 2.  Consider using create_from_svc(service_name) instead.')
      end
  end

  it 'raises an ArgumentError if Rabbit service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::CarrotClient.create_from_svc('non-existent-rabbit')}.to raise_error(ArgumentError,
      'Service with name non-existent-rabbit not found')
  end

end