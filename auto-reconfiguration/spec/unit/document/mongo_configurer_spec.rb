File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'mongo'
require 'cfautoconfig/document/mongodb_configurer'

describe 'AutoReconfiguration::Mongo' do

  before(:each) do
    ENV['VCAP_APPLICATION'] = '{"name":"test"}'
    ENV['VCAP_SERVICES'] = '{"mongodb-1.8":[{"name": "mongo-1","label": "mongodb-1.8",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40","port": 12345, ' +
      '"username": "8d93ae0a", "password": "7cf3c0e3","name": "m1", "db": "db"}}]}'
  end

  it 'auto-configures Mongo on initialize with host and port' do
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    mongo.host_to_try.should == mongo.send(:format_pair, '10.20.30.40', 12345)
  end

  it 'auto-configures DB with CF authentication values on db call' do
    module Mongo
      module Support
        def validate_db_name(db_name)
          db_name.should == 'db'
          db_name
        end
      end
      class DB
        def authenticate(username, password, save_auth=true)
          username.should == '8d93ae0a'
          password.should == '7cf3c0e3'
          true
        end
      end
    end
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    db = mongo.db('test')
  end

  it 'auto-configures DB with CF authentication values on [] shortcut call' do
    module Mongo
      module Support
        def validate_db_name(db_name)
          db_name.should == 'db'
          db_name
        end
      end
      class DB
        def authenticate(username, password, save_auth=true)
          username.should == '8d93ae0a'
          password.should == '7cf3c0e3'
          true
        end
      end
    end
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    db = mongo['test']
  end

  it 'does not auto-configure DB on db call if db-name is admin' do
    module Mongo
      module Support
        def validate_db_name(db_name)
          db_name.should == 'admin'
          db_name
        end
      end
      class DB
        def authenticate(username, password, save_auth=true)
          raise(Mongo::AuthenticationError, "Authenticate should not have been called!")
        end
      end
    end
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    db = mongo.db('admin')
  end

  it 'does not auto-configure DB on [] shortcut call if db-name is admin' do
    module Mongo
      module Support
        def validate_db_name(db_name)
          db_name.should == 'admin'
          db_name
        end
      end
      class DB
        def authenticate(username, password, save_auth=true)
          raise(Mongo::AuthenticationError, "Authenticate should not have been called!")
        end
      end
    end
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    db = mongo['admin']
  end

  it 'does not auto-configure Mongo if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    mongo.host_to_try.should == mongo.send(:format_pair, '127.0.0.1', 27017)
  end

  it 'does not auto-configure DB if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    module Mongo
      module Support
        def validate_db_name(db_name)
          db_name.should == 'test'
          db_name
        end
      end
      class DB
        def authenticate(username, password, save_auth=true)
          raise(Mongo::AuthenticationError, "Authenticate should not have been called!")
        end
      end
    end
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    db = mongo.db('test')
  end

  it 'disables Mongo auto-reconfig if DISABLE_AUTO_CONFIG includes mongodb' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:mongodb"
    load 'cfautoconfig/document/mongodb_configurer.rb'
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    mongo.host_to_try.should == mongo.send(:format_pair, '127.0.0.1', 27017)
  end
end