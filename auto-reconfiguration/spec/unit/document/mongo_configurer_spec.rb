require 'spec_helper'
require 'mongo'
require 'cfautoconfig/document/mongodb_configurer'

describe 'AutoReconfiguration::Mongo' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"mongodb-1.8":[{"name": "mongo-1","label": "mongodb-1.8",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40","port": 1234, ' +
      '"password": "mypass","name": "m1", "db": "db"}}]}'
    load 'cfruntime/properties.rb'
  end

  it 'auto-configures Mongo on initialize with host and port' do
    # TODO: This requires a mongo service running on the host and port provided - should we use mock instances?
    # mongo = Mongo::Connection.new('127.0.0.1', 27017)
  end

end