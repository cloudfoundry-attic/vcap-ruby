require 'spec_helper'
require 'cfruntime/properties'

describe 'CFRuntime::RedisParser' do
  it 'parses a redis service' do
    svcs = {
      "redis-#{redis_version}" => [create_redis_service('redis-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "redis",
        :version => "#{redis_version}",
        :name => "redis-test",
        :username => "testuser",
        :password => "testpw",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :database => "redisdata",
        :url => "redis://testuser:testpw@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/redisdata"
      }
      CFRuntime::CloudApp.service_props('redis').should == expected
    end
  end
end