require 'spec_helper'
require 'cf-runtime/mongodb'

describe 'CFRuntime::MongoClient' do

  before(:each) do
    module Mongo
      class DB
        def authenticate(username,password)
          username.should == "testuser"
          password.should == "testpw"
        end
      end
    end
  end

  it 'creates a client with a Mongo service by type and additional options' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      db = CFRuntime::MongoClient.create(:connect=>false).db
      db.name.should == "db"
      db.connection.host_to_try.should == [SOME_SERVER,SOME_SERVICE_PORT]
    end
  end

  it 'creates a client with a Mongo service by name and additional options' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      db = CFRuntime::MongoClient.create_from_svc('mongo-test',:connect=>false).db
      db.name.should == "db"
      db.connection.host_to_try.should == [SOME_SERVER,SOME_SERVICE_PORT]
    end
  end

  it 'creates a client with a Mongo service by type and gives access to native connection object and db_name' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      conn = CFRuntime::MongoClient.create(:connect=>false).target
      db_name = CFRuntime::MongoClient.db_name()
      db = conn.db(db_name)
      db.name.should == "db"
      db.connection.host_to_try.should == [SOME_SERVER,SOME_SERVICE_PORT]
    end
  end

  it 'creates a client with a Mongo service by name and gives access to native connection object and db_name' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      conn = CFRuntime::MongoClient.create_from_svc('mongo-test',:connect=>false).target
      db_name = CFRuntime::MongoClient.db_name_from_svc('mongo-test')
      db = conn.db(db_name)
      db.name.should == "db"
      db.connection.host_to_try.should == [SOME_SERVER,SOME_SERVICE_PORT]
    end
  end

  it 'raises an ArgumentError on create if no service of Mongo type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::MongoClient.create}.to raise_error(ArgumentError,
      'Expected 1 service of mongodb type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError on create if multiple services of Mongo type found' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test'),
        create_mongo_service('mongo-test2')]}
      with_vcap_services(svcs) do
        expect{CFRuntime::MongoClient.create}.to raise_error(ArgumentError,
          'Expected 1 service of mongodb type, but found 2.  Consider using create_from_svc(service_name) instead.')
      end
  end

  it 'raises an ArgumentError on create if Mongo service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::MongoClient.create_from_svc('non-existent-mongo')}.to raise_error(ArgumentError,
      'Service with name non-existent-mongo not found')
  end
  it 'raises an ArgumentError on db if no service of Mongo type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::MongoClient.db_name}.to raise_error(ArgumentError,
      'Expected 1 service of mongodb type, but found 0.  Consider using db_name_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError on db if multiple services of Mongo type found' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test'),
        create_mongo_service('mongo-test2')]}
      with_vcap_services(svcs) do
        expect{CFRuntime::MongoClient.db_name}.to raise_error(ArgumentError,
          'Expected 1 service of mongodb type, but found 2.  Consider using db_name_from_svc(service_name) instead.')
      end
  end

  it 'raises an ArgumentError on db if Mongo service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::MongoClient.db_name_from_svc('non-existent-mongo')}.to raise_error(ArgumentError,
      'Service with name non-existent-mongo not found')
  end
end
