require 'spec_helper'
require 'cfruntime/properties'

describe 'CFRuntime::MysqlParser' do
  it 'parses a mysql service' do
    svcs = {
      "mysql-#{mysql_version}" => [create_mysql_service('mysql-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "mysql",
        :version => "#{mysql_version}",
        :name => "mysql-test",
        :username => "testuser",
        :password => "testpw",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :database => "mysqldatabase"
      }
      CFRuntime::CloudApp.service_props('mysql').should == expected
    end
  end
end