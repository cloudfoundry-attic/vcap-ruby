require 'spec_helper'
require 'cfruntime/properties'

describe 'CFRuntime::DefaultParser' do
  it 'returns the specified service info with symbolized map keys' do
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
    end
  end
end