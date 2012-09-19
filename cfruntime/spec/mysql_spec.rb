require 'spec_helper'
require 'cfruntime/mysql'

describe 'CFRuntime::Mysql2Client' do

  before(:each) do
    module Mysql2
      class Client
        attr_accessor :opts
        def connect(user, pass, host, port, database, socket, flags)
          @opts = {:user=>user,:pass=>pass, :host=>host, :port=>port, :database=>database, :socket=>socket}
        end
      end
    end
  end

  it 'creates a client with a MySQL service by type and no additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::Mysql2Client.create
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>nil}
    end
  end

  it 'creates a client with a MySQL service by type and additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::Mysql2Client.create({:socket=>"sock"})
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>"sock"}
    end
  end

  it 'creates a client with a MySQL service by name and no additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::Mysql2Client.create_from_svc('mysql-test')
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>nil}
    end
  end

  it 'creates a client with a MySQL service by name and additional options' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::Mysql2Client.create_from_svc('mysql-test',{:socket=>"sock"})
      client.opts.should=={:user=>"testuser",:pass=>"testpw", :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT,
        :database=>"mysqldatabase", :socket=>"sock"}
    end
  end

  it 'raises an ArgumentError if no service of MySQL type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::Mysql2Client.create}.to raise_error(ArgumentError,
      'Expected 1 service of mysql type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError if multiple services of MySQL type found' do
    svcs = {"mysql-#{mysql_version}"=>[create_mysql_service('mysql-test'),
        create_mysql_service('mysql-test2')]}
    with_vcap_services(svcs) do
      expect{CFRuntime::Mysql2Client.create}.to raise_error(ArgumentError,
        'Expected 1 service of mysql type, but found 2.  Consider using create_from_svc(service_name) instead.')
    end
  end

  it 'raises an ArgumentError if MySQL service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::Mysql2Client.create_from_svc('non-existent-mysql')}.to raise_error(ArgumentError,
      'Service with name non-existent-mysql not found')
  end
end