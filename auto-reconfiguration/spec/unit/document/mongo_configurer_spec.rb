File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'mongo'
require 'cfautoconfig/document/mongodb_configurer'

describe 'AutoReconfiguration::Mongo' do

  before(:each) do
    ENV['VCAP_APPLICATION'] = '{"name":"test"}'
    ENV['VCAP_SERVICES'] = '{"mongodb-1.8":[{"name": "mongo-1","label": "mongodb-1.8",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40","port": 12345, ' +
      '"password": "mypass","name": "m1", "db": "db"}}]}'
    load 'cfruntime/properties.rb'
  end

  it 'auto-configures Mongo on initialize with host and port' do
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    mongo.instance_variable_get("@host_to_try").should == mongo.send(:format_pair, '10.20.30.40', 12345)
  end

  it 'does not auto-configure Mongo if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    mongo.instance_variable_get("@host_to_try").should == mongo.send(:format_pair, '127.0.0.1', 27017)
  end

  it 'disables Mongo auto-reconfig if DISABLE_AUTO_CONFIG includes mongodb' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:mongodb"
    load 'cfautoconfig/document/mongodb_configurer.rb'
    mongo = Mongo::Connection.new('127.0.0.1', 27017, {:connect => false})
    mongo.instance_variable_get("@host_to_try").should == mongo.send(:format_pair, '127.0.0.1', 27017)
  end
end