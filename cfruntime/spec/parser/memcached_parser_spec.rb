require 'spec_helper'
require 'cf-runtime/properties'

describe 'CFRuntime::MemcachedParser' do
  it 'parses a memcached service' do
    svcs = {
      "memcached-#{memcached_version}" => [create_memcached_service('memcached-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "memcached",
        :version => "#{memcached_version}",
        :name => "memcached-test",
        :username => "testuser",
        :password => "testpw",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :url => "memcached://testuser:testpw@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/"
      }
      CFRuntime::CloudApp.service_props('memcached').should == expected
    end
  end
end
