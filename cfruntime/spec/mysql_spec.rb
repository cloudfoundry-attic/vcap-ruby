require File.join(File.dirname(__FILE__), 'spec_helper')
require 'cfruntime/mysql'

describe 'CFRuntime::Mysql2Client' do
  include CFRuntime::Test

  before(:each) do
    #redirect the connect method to a test_connect method that exposes params passed during initialization
    #We do this as there is no other way to mock a connection attempt
    module Mysql2
      class Client
        attr_accessor :opts
        def test_connect(user, pass, host, port, database, socket, flags)
          @opts = {:user=>user,:pass=>pass, :host=>host, :port=>port, :database=>database, :socket=>socket}
        end
      end
    end
    Mysql2::Client.send( :alias_method, :original_connect, :connect)
    Mysql2::Client.send( :alias_method, :connect, :test_connect )
  end

  after(:each) do
    Mysql2::Client.send(:alias_method,:connect, :original_connect)
    module Mysql2
      class Client
        undef_method :test_connect
      end
    end
  end

  it 'creates a client with a MySQL service by type and no additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      client = CFRuntime::Mysql2Client.create
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>nil}
    end
  end

  it 'creates a client with a MySQL service by type and additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      client = CFRuntime::Mysql2Client.create({:socket=>"sock"})
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>"sock"}
    end
  end

  it 'creates a client with a MySQL service by name and no additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      client = CFRuntime::Mysql2Client.create_from_svc('mysql-test')
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>nil}
    end
  end

  it 'creates a client with a MySQL service by name and additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      client = CFRuntime::Mysql2Client.create_from_svc('mysql-test',{:socket=>"sock"})
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>"sock"}
    end
  end

  it 'raises an ArgumentError if no service of MySQL type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::Mysql2Client.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if multiple services of MySQL type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::Mysql2Client.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if MySQL service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::Mysql2Client.create_from_svc('non-existent-mysql')}.to raise_error(ArgumentError,
      'Service with name non-existent-mysql not found')
  end
end