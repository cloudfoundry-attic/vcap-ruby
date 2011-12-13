require File.join(File.dirname(__FILE__), 'spec_helper')
require 'cfruntime/carrot'

describe 'CFRuntime::CarrotClient' do
  include CFRuntime::Test

  before(:each) do
    #Add access to the opts variable stored on new
    class Carrot
      def opts_for_cf
        @opts
      end
    end
  end

  it 'creates a client with a Rabbit service by type and no additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      carrot = CFRuntime::CarrotClient.create
      carrot.opts_for_cf.should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost'}
    end
  end

  it 'creates a client with a Rabbit service by type and additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    opts = {:some=>'thing'}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      carrot = CFRuntime::CarrotClient.create(opts)
      carrot.opts_for_cf.should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost', :some=>'thing'}
    end
  end

  it 'creates a client with a Rabbit service by name and no additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      carrot = CFRuntime::CarrotClient.create_from_svc('rabbit-test')
      carrot.opts_for_cf.should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost'}
    end
  end

  it 'creates a client with a Rabbit service by name and additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    opts = {:some=>'thing'}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      carrot = CFRuntime::CarrotClient.create_from_svc('rabbit-test',opts)
      carrot.opts_for_cf.should == { :host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost', :some=>'thing'}
    end
  end

  it 'raises an ArgumentError if no service of Rabbit type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::CarrotClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if multiple services of Rabbit type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::CarrotClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if Rabbit service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::CarrotClient.create_from_svc('non-existent-rabbit')}.to raise_error(ArgumentError,
      'Service with name non-existent-rabbit not found')
  end

end