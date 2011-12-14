require 'mysql2'
require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'cfautoconfig/relational/mysql_configurer'

describe 'AutoReconfiguration::Mysql' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"mysql-5.1":[{"name": "mysql-1","label": "mysql-5.1",' +
      '"plan": "free", "credentials": { "hostname": "10.20.30.40",' +
      '"port": 1234,"name": "cfdb","user": "cfuser","username": "cfuser","password": "cfpasswd"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
    @dbopts = {}
    @dbopts[:username] = 'user'
    @dbopts[:password] = 'passwd'
    @dbopts[:host] = 'localhost'
    @dbopts[:port] = 3306
    @dbopts[:database] = 'test'
    module Mysql2
      class Client
        def charset_name=(name)
        end
        def ssl_set(sslkey, sslcert, sslca, sslcapath, sslcipher)
        end
        def init_connection
        end
      end
    end
  end

  it 'auto-configures Mysql on initialize with options' do
    module Mysql2
      class Client
        def connect user, pass, host, port, database, socket, flags
          user.should == 'cfuser'
          pass.should == 'cfpasswd'
          host.should == '10.20.30.40'
          port.should == 1234
          database.should == 'cfdb'
        end
      end
    end
    db = Mysql2::Client.new(@dbopts)
  end

  it 'does not auto-configure Mysql if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    module Mysql2
      class Client
        def connect user, pass, host, port, database, socket, flags
          user.should == 'user'
          pass.should == 'passwd'
          host.should == 'localhost'
          port.should == 3306
          database.should == 'test'
        end
      end
    end
    db = Mysql2::Client.new(@dbopts)
  end

  it 'disables Mysql auto-reconfig if DISABLE_AUTO_CONFIG includes mysql' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:mysql:mongodb"
    load 'cfautoconfig/relational/mysql_configurer.rb'
    module Mysql2
      class Client
        def connect user, pass, host, port, database, socket, flags
          user.should == 'user'
          pass.should == 'passwd'
          host.should == 'localhost'
          port.should == 3306
          database.should == 'test'
        end
      end
    end
    db = Mysql2::Client.new(@dbopts)
  end
end