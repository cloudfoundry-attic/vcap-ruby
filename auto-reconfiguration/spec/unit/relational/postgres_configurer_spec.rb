require 'pg'
require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'cfautoconfig/relational/postgres_configurer'

describe 'AutoReconfiguration::Postgres' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"postgresql-9.0":[{"name": "postgres-1","label": "postgresql-9.0",' +
      '"plan": "free", "credentials": { "node_id": "postgresql_node_4","hostname": "10.20.30.40",' +
      '"port": 8552,"password": "svcpw","name": "svcdb","username": "svcuser"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
    load 'cfruntime/properties.rb'
  end

  it 'auto-configures PGConn.open with Array arguments' do
    expected_conn_string= attempt_pg_open('localhost','5689', {:foo=>'bar'},nil,'testdb','testuser','testpw',:connect_timeout=>1)
    expected_conn_string.should == "connect_timeout='1' host='10.20.30.40' port='8552' options='{:foo=>\"bar\"}' dbname='svcdb' user='svcuser' password='svcpw'"
  end

  it 'auto-configures PGConn.open with Array arguments missing some' do
    expected_conn_string=attempt_pg_open('localhost','5689', :dbname => 'testdb', :user => 'testuser', :password => 'testpw', :connect_timeout=>1)
    expected_conn_string.should == "dbname='svcdb' user='svcuser' password='svcpw' connect_timeout='1' host='10.20.30.40' port='8552'"
  end

  it 'auto-configures PGConn.open with connection hash argument' do
    expected_conn_string=attempt_pg_open(:host=>'localhost',:port=>'5689', :dbname => 'testdb', :user => 'testuser', :password => 'testpw', :connect_timeout=>1)
    expected_conn_string.should == "host='10.20.30.40' port='8552' dbname='svcdb' user='svcuser' password='svcpw' connect_timeout='1'"
  end

  it 'auto-configures PGConn.open with connection hash argument missing some items' do
    expected_conn_string=attempt_pg_open(:host=>'localhost',:dbname => 'testdb', :connect_timeout=>1)
    expected_conn_string.should == "host='10.20.30.40' dbname='svcdb' connect_timeout='1' port='8552' user='svcuser' password='svcpw'"
  end

  it 'auto-configures PGConn.open with no arguments' do
    expected_conn_string=attempt_pg_open(:connect_timeout=>1)
    expected_conn_string.should == "connect_timeout='1' dbname='svcdb' host='10.20.30.40' port='8552' user='svcuser' password='svcpw'"
  end

  it 'auto-configures PGConn.open with connection string' do
    expected_conn_string=attempt_pg_open("host=localhost dbname=testdb port=8552 user=testuser password=testpw connect_timeout=1")
    expected_conn_string.should == "host='10.20.30.40' dbname='svcdb' port='8552' user='svcuser' password='svcpw' connect_timeout=1"
  end

  it 'auto-configures PGConn.open with connection string missing some args' do
    expected_conn_string=attempt_pg_open("host=localhost port=8552 user=testuser connect_timeout=1")
    expected_conn_string.should == "host='10.20.30.40' port='8552' user='svcuser' connect_timeout=1 dbname='svcdb' password='svcpw'"
  end

  it 'auto-configures PGConn.connect' do
     expected_conn_string= attempt_pg_connect('localhost','5689', {:foo=>'bar'},nil,'testdb','testuser','testpw',:connect_timeout=>1)
     expected_conn_string.should == "connect_timeout='1' host='10.20.30.40' port='8552' options='{:foo=>\"bar\"}' dbname='svcdb' user='svcuser' password='svcpw'"
   end

   it 'auto-configures PGConn.connect_start' do
      expected_conn_string= attempt_pg_connect_start('localhost','5689', {:foo=>'bar'},nil,'testdb','testuser','testpw',:connect_timeout=>1)
      expected_conn_string.should == "connect_timeout='1' host='10.20.30.40' port='8552' options='{:foo=>\"bar\"}' dbname='svcdb' user='svcuser' password='svcpw'"
    end

  it 'does not auto-configure PGConn.open if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    expected_conn_string=attempt_pg_open("host=localhost port=8552 user=testuser connect_timeout=1")
    expected_conn_string.should == ""
  end

  it 'does not open PGconn class to apply methods twice' do
     load 'cfautoconfig/relational/postgres_configurer.rb'
     #This would blow up massively (stack trace too deep) if we
     #aliased the connect,open, or connect_start methods twice
     expected_conn_string= attempt_pg_connect_start('localhost','5689', {:foo=>'bar'},nil,'testdb','testuser','testpw',:connect_timeout=>1)
     expected_conn_string.should == "connect_timeout='1' host='10.20.30.40' port='8552' options='{:foo=>\"bar\"}' dbname='svcdb' user='svcuser' password='svcpw'"
     expected_conn_string= attempt_pg_connect('localhost','5689', {:foo=>'bar'},nil,'testdb','testuser','testpw',:connect_timeout=>1)
     expected_conn_string.should == "connect_timeout='1' host='10.20.30.40' port='8552' options='{:foo=>\"bar\"}' dbname='svcdb' user='svcuser' password='svcpw'"
     expected_conn_string= attempt_pg_open('localhost','5689', {:foo=>'bar'},nil,'testdb','testuser','testpw',:connect_timeout=>1)
     expected_conn_string.should == "connect_timeout='1' host='10.20.30.40' port='8552' options='{:foo=>\"bar\"}' dbname='svcdb' user='svcuser' password='svcpw'"
   end

  it 'disables Postgres auto-reconfig if DISABLE_AUTO_CONFIG includes postgresql' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:postgresql:mongodb"
    load 'cfautoconfig/relational/postgres_configurer.rb'
    expected_conn_string=attempt_pg_open("host=localhost port=8552 user=testuser connect_timeout=1")
    expected_conn_string.should == ""
  end

  #Underlying pc code is in C. Can't mock connection attempt.
  def attempt_pg_open(*args)
    expected_conn_string=''
      begin
        PGconn.open(*args) do|connection_string|
          expected_conn_string = connection_string
        end
      rescue PGError=>e
        #Excepted connection timeout
        if !e.message=~"timeout expired"
          raise e
        end
      end
    expected_conn_string
  end

  def attempt_pg_connect(*args)
    expected_conn_string=''
      begin
        PGconn.connect(*args) do|connection_string|
          expected_conn_string = connection_string
        end
      rescue PGError=>e
        #Excepted connection timeout
        if !e.message=~"timeout expired"
          raise e
        end
      end
    expected_conn_string
  end

  def attempt_pg_connect_start(*args)
    expected_conn_string=''
      begin
        PGconn.connect_start(*args) do|connection_string|
          expected_conn_string = connection_string
        end
      rescue PGError=>e
        #Excepted connection timeout
        if !e.message=~"timeout expired"
          raise e
        end
      end
    expected_conn_string
  end
end