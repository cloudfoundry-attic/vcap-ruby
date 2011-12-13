require File.join(File.dirname(__FILE__), 'spec_helper')
require 'cfruntime/amqp'

describe 'CFRuntime::AMQPClient' do
  include CFRuntime::Test

  before(:each) do
    @mock_connection = mock("connection")
  end

  it 'creates a client with a Rabbit service by type and no additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      mock_client = mock("client")
      AMQP.client = mock_client
      mock_client.should_receive(:connect).with({:host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost'}).and_return(@mock_connection)
      @mock_connection.should_receive(:on_open)
      CFRuntime::AMQPClient.create
    end
  end

  it 'creates a client with a Rabbit service by type and additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    addl_opts = {:some=>'thing'}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      mock_client = mock("client")
      AMQP.client = mock_client
      mock_client.should_receive(:connect).with({:host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost', :some=>'thing'}).and_return(@mock_connection)
      @mock_connection.should_receive(:on_open)
      CFRuntime::AMQPClient.create(addl_opts) do
        #TODO check this - not being called but may be b/c block
        puts "Yeah baby"
      end
    end
  end

  it 'creates a client with a Rabbit service by name and no additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      mock_client = mock("client")
      AMQP.client = mock_client
      mock_client.should_receive(:connect).with({:host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost'}).and_return(@mock_connection)
      @mock_connection.should_receive(:on_open)
      CFRuntime::AMQPClient.create_from_svc('rabbit-test')
    end
  end

  it 'creates a client with a Rabbit service by name and additional options' do
    svcs = {"rabbitmq-#{rabbit_version}"=>[create_rabbit_srs_service('rabbit-test','testvhost')]}
    addl_opts = {:some=>'thing'}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      mock_client = mock("client")
      AMQP.client = mock_client
      mock_client.should_receive(:connect).with({:host => "#{SOME_SERVER}", :port =>SOME_SERVICE_PORT, :user=>'rabbituser',
        :pass=>'rabbitpass', :vhost=>'testvhost', :some=>'thing'}).and_return(@mock_connection)
      @mock_connection.should_receive(:on_open)
      CFRuntime::AMQPClient.create_from_svc('rabbit-test',addl_opts) do
        #TODO check this - not being called but may be b/c block
        puts "Yeah"
      end
    end
  end

  it 'raises an ArgumentError if no service of Rabbit type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::AMQPClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if multiple services of Rabbit type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::AMQPClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if Rabbit service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::AMQPClient.create_from_svc('non-existent-rabbit')}.to raise_error(ArgumentError,
      'Service with name non-existent-rabbit not found')
  end

end