require 'spec_helper'
require 'cf-runtime/properties'

describe 'CFRuntime::CloudApp' do

  it 'runs standalone' do
    CFRuntime::CloudApp.running_in_cloud?.should == false
  end

  it 'runs in the cloud' do
    with_vcap_application do
      CFRuntime::CloudApp.running_in_cloud?.should == true
    end
  end

  it 'exposes host and port in the cloud' do
    with_vcap_application do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.host.should == SOME_SERVER
      CFRuntime::CloudApp.port.should == "#{SOME_PORT}"
    end
  end

  it 'works without a service' do
    with_vcap_application do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      no_svc = CFRuntime::CloudApp.service_props('test')
      no_svc.should == nil
    end
  end

  it 'works with a service' do
    svcs = {
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test')]
    }
    with_vcap_services(svcs) do
      mongo_svc = CFRuntime::CloudApp.service_props('mongo-test')
      mongo_svc[:name].should == "mongo-test"
    end
  end

  it 'exposes a single service under the name of the service type' do
    svcs = {
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test')]
    }
    with_vcap_services(svcs) do
      mongo_svc = CFRuntime::CloudApp.service_props('mongodb')
      mongo_svc[:name].should == "mongo-test"
    end
  end

  it 'works with two services of the same type' do
    svcs = {
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test1'), create_mongo_service('mongo-test2')]
    }
    with_vcap_services(svcs) do
      CFRuntime::CloudApp.service_props('mongodb').should == nil
      CFRuntime::CloudApp.service_props('mongo-test1')[:name].should == "mongo-test1"
      CFRuntime::CloudApp.service_props('mongo-test2')[:name].should == "mongo-test2"
    end
  end

  it 'works with services of different types' do
    svcs = {
      "redis-#{redis_version}" => [create_redis_service('redis-test')],
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test')]
    }
    with_vcap_services(svcs) do
      CFRuntime::CloudApp.service_props('mongodb').should_not == nil
      CFRuntime::CloudApp.service_props('redis').should_not == nil
      CFRuntime::CloudApp.service_props('mongo-test')[:name].should == "mongo-test"
      CFRuntime::CloudApp.service_props('redis-test')[:name].should == "redis-test"
    end
  end

  it 'exposes available service names' do
    svcs = {
      "redis-#{redis_version}" => [create_redis_service('redis-test')],
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test')]
    }
    with_vcap_services(svcs) do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.service_names.sort.should == ['mongo-test', 'redis-test']
    end
  end

  it 'exposes empty list of services when none defined' do
    with_vcap_services({}) do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.service_names.should == []
    end
  end

  it 'enumerates available service names based on type and empty list if no service is defined' do
    svcs = {
      "redis-#{redis_version}" => [create_redis_service('redis-test')],
      "mongodb-#{mongo_version}" => [create_mongo_service('mongo-test'), create_mongo_service('mongo-test2')]
    }
    with_vcap_services(svcs) do
      CFRuntime::CloudApp.running_in_cloud?.should == true
      CFRuntime::CloudApp.service_names_of_type('mongodb').sort.should == ['mongo-test', 'mongo-test2']
      CFRuntime::CloudApp.service_names_of_type('mysql').should == []
    end
  end

  it 'exhibits default parsing behavior if no custom parser specified' do
    svcs = { "filesystem-1.0" => ["{\"name\":\"filesystem-d460f\",\"label\":" +
        "\"filesystem-1.0\",\"plan\":\"free\",\"tags\":[\"Persistent filesystem service\",\"filesystem-1.0\"," +
        "\"filesystem\"],\"credentials\":{\"internal\":{\"fs_type\":\"local\",\"name\":\"fc662d2b-59ef-4de3-9912-90809ec5d080\"," +
        "\"local_path\":\"/var/vcap/store/fss_backend1\"}}}"]
    }
    with_vcap_services(svcs) do
      expected = { :label => "filesystem-1.0",
        :version => "1.0",
        :name => "filesystem-d460f",
        :plan => "free",
        :tags => ["Persistent filesystem service", "filesystem-1.0", "filesystem"],
        :credentials => { :internal => { :fs_type=>"local",
                                         :name=>"fc662d2b-59ef-4de3-9912-90809ec5d080",
                                         :local_path=>"/var/vcap/store/fss_backend1" }}
      }
      CFRuntime::CloudApp.service_props('filesystem').should == expected
      CFRuntime::CloudApp.service_props('filesystem-d460f').should == expected
    end
  end
end
