require 'spec_helper'
require 'cfruntime/properties'

describe 'CFRuntime::MongoParser' do
  it 'parses a mongo service without a URL (old format)' do
    svcs = {
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "mongodb",
        :version => "#{mongo_version}",
        :name => "mongo-test",
        :username => "testuser",
        :password => "testpw",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :db => "db",
        :url => "mongodb://testuser:testpw@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/db"
      }
      CFRuntime::CloudApp.service_props('mongodb').should == expected
    end
  end

  it 'parses a mongo service with a URL (new format)' do
    svcs = {
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test', true)]
    }
    with_vcap_services(svcs) do
      expected = { :label => "mongodb",
        :version => "#{mongo_version}",
        :name => "mongo-test",
        :username => "testuser",
        :password => "testpw",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :db => "db",
        :url => "mongodb://testuser:testpw@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/db"
      }
      CFRuntime::CloudApp.service_props('mongodb').should == expected
    end
  end
end