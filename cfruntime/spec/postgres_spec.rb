require 'spec_helper'
require 'cfruntime/postgres'

describe 'CFRuntime::PGClient' do

  it 'creates a client with a Postgres service by type and additional options' do
    svcs = {"postgresql-#{postgres_version}"=>[create_postgres_service('pg-test')]}
    with_vcap_services(svcs) do
      begin
        CFRuntime::PGClient.create(:connect_timeout=>1) do|cfopts|
          cfopts.should == {:connect_timeout=>1, :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT, :user=>"testuser",
            :password=>"testpw", :dbname=>"pgdatabase"}
        end
      rescue PGError=>e
        #Excepted connection timeout
        if !e.message=~"timeout expired"
          raise e
        end
      end
    end
  end

  it 'creates a client with a Postgres service by name and additional options' do
    svcs = {"postgresql-#{postgres_version}"=>[create_postgres_service('pg-test')]}
    with_vcap_services(svcs) do
      begin
        CFRuntime::PGClient.create_from_svc('pg-test',:connect_timeout=>1) do|cfopts|
          cfopts.should == {:connect_timeout=>1, :host=>SOME_SERVER, :port=>SOME_SERVICE_PORT, :user=>"testuser",
            :password=>"testpw", :dbname=>"pgdatabase"}
        end
      rescue PGError=>e
        #Excepted connection timeout
        if !e.message=~"timeout expired"
          raise e
        end
      end
    end
  end

  it 'raises an ArgumentError if no service of Postgresql type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::PGClient.create}.to raise_error(ArgumentError,
      'Expected 1 service of postgresql type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError if multiple services of Postgresql type found' do
    svcs = {"postgresql-#{postgres_version}"=>[create_postgres_service('pg-test'),
        create_postgres_service('pg-test2')]}
    with_vcap_services(svcs) do
      expect{CFRuntime::PGClient.create}.to raise_error(ArgumentError,
        'Expected 1 service of postgresql type, but found 2.  Consider using create_from_svc(service_name) instead.')
    end
  end

  it 'raises an ArgumentError if Postgres service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::PGClient.create_from_svc('non-existent-postgres')}.to raise_error(ArgumentError,
      'Service with name non-existent-postgres not found')
  end
end