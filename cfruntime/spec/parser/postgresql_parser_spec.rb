require 'spec_helper'
require 'cfruntime/properties'

describe 'CFRuntime::PostgresqlParser' do
  it 'parses a postgres service' do
    svcs = {
      "postgresql-#{postgres_version}" => [create_postgres_service('pg-test')]
    }
    with_vcap_services(svcs) do
      expected = { :label => "postgresql",
        :version => "#{postgres_version}",
        :name => "pg-test",
        :username => "testuser",
        :password => "testpw",
        :host => SOME_SERVER,
        :port => SOME_SERVICE_PORT,
        :database => "pgdatabase",
        :url => "postgres://testuser:testpw@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/pgdatabase"
      }
      CFRuntime::CloudApp.service_props('postgresql').should == expected
    end
  end
end