require File.join(File.dirname(__FILE__), 'spec_helper')
require 'cfruntime/mongodb'

describe 'CFRuntime::MongoClient' do
  include CFRuntime::Test

  before(:each) do
    #redirect the authenticate method to a test_authenticate method that exposes params passed
    #We do this as there is no other way to mock an authentication attempt
    module Mongo
      class DB
        attr_accessor :username, :password
        def test_authenticate(username,password)
          @username = username
          @password = password
        end
      end
    end
    Mongo::DB.send( :alias_method, :original_authenticate, :authenticate)
    Mongo::DB.send( :alias_method, :authenticate, :test_authenticate)
  end

  after(:each) do
    Mongo::DB.send(:alias_method,:authenticate, :test_authenticate)
    module Mongo
      class DB
        undef_method :test_authenticate
      end
    end
  end

  it 'creates a client with a Mongo service by type and additional options' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      db = CFRuntime::MongoClient.create(:connect=>false)
      db.name.should == "db"
      db.username.should == "testuser"
      db.password.should == "testpw"
      db.connection.host_to_try.should == [SOME_SERVER,SOME_SERVICE_PORT]
    end
  end

  it 'creates a client with a Mongo service by name and additional options' do
    svcs = {"mongodb-#{mongo_version}"=>[create_mongo_service('mongo-test')]}
    with_vcap_services(svcs) do
      load 'cfruntime/properties.rb'
      db = CFRuntime::MongoClient.create_from_svc('mongo-test',:connect=>false)
      db.name.should == "db"
      db.username.should == "testuser"
      db.password.should == "testpw"
      db.connection.host_to_try.should == [SOME_SERVER,SOME_SERVICE_PORT]
    end
  end

  it 'raises an ArgumentError if no service of Mongo type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::MongoClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if multiple services of Mongo type found' do
    #TODO validate error msg
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::MongoClient.create}.to raise_error(ArgumentError)
  end

  it 'raises an ArgumentError if Mongo service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expect{CFRuntime::MongoClient.create_from_svc('non-existent-mongo')}.to raise_error(ArgumentError,
      'Service with name non-existent-mongo not found')
  end
end