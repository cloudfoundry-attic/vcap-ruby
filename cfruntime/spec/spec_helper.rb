# Copyright (c) 2009-2011 VMware, Inc.
$:.unshift File.join(File.dirname(__FILE__), '..')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

home = File.join(File.dirname(__FILE__), '/..')
ENV['BUNDLE_GEMFILE'] = "#{home}/Gemfile"

require 'bundler'
require 'bundler/setup'
require 'rubygems'
require 'rspec'
require 'json/pure'

module CFRuntime
  module Test

    SOME_SERVER = '172.30.48.73'
    SOME_PORT = 56789
    SOME_SERVICE_PORT = 25046

    def with_vcap_application
      vcap_app = {"instance_id"=>"#{secure_uuid}",
        "instance_index"=>0,
        "name"=>"tr_env",
        "uris"=>["tr_env.cloudfoundry.com"],
        "users"=>["trisberg@vmware.com"],
        "version"=>"#{secure_uuid}",
        "start"=>"2011-11-05 13:29:32 +0000",
        "runtime"=>"ruby19",
        "state_timestamp"=>1320499772,
        "port"=>SOME_PORT,
        "limits"=>{"fds"=>256,"mem"=>134217728,"disk"=>2147483648},
        "host"=>"#{SOME_SERVER}"}
      ENV['VCAP_APPLICATION'] = JSON vcap_app
      yield
    end

    def with_vcap_services(services)
      # with_vcap_application
      ENV['VCAP_SERVICES'] = JSON services
      yield
    end

    # this is in commons.rb - could require this maybe?
    def secure_uuid
      result = File.open('/dev/urandom') { |x| x.read(16).unpack('H*')[0] }
    end

    def mongo_version
      "1.8"
    end

    def redis_version
      "2.2"
    end

    def rabbit_version
      "2.4"
    end

    def mysql_version
      "0.3.11"
    end

    def create_mongo_service(name)
      vcap_svc = create_service(name, "mongodb", mongo_version)
      vcap_svc["credentials"]["db"] = "db"
      vcap_svc["credentials"]["username"] = "testuser"
      vcap_svc["credentials"]["password"] = "testpw"
      vcap_svc
    end

    def create_redis_service(name)
      create_service(name, "redis", redis_version)
    end

    def create_mysql_service(name)
      vcap_svc = create_service(name, "mysql", mysql_version)
      vcap_svc["credentials"]["name"] = "mysqldatabase"
      vcap_svc["credentials"]["username"] = "testuser"
      vcap_svc["credentials"]["password"] = "testpw"
      vcap_svc
    end

    def create_rabbit_service(name, vhost=nil)
      {"name"=>"#{name}",
      "label"=>"rabbitmq-#{rabbit_version}",
      "plan"=>"free",
      "tags"=>["rabbitmq","rabbitmq-#{rabbit_version}"],
      "credentials"=>{
        "hostname"=>"#{SOME_SERVER}",
        "port"=>SOME_SERVICE_PORT,
        "user"=>"#{secure_uuid}",
        "pass"=>"#{secure_uuid}",
        "vhost"=>"#{vhost}"}
      }
    end

    def create_rabbit_srs_service(name, vhost=nil)
      if vhost
        url = "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/#{vhost}"
      else
        url = "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}"
      end
      {"name"=>"#{name}",
      "label"=>"rabbitmq-#{rabbit_version}",
      "plan"=>"free",
      "tags"=>["rabbitmq","rabbitmq-#{rabbit_version}"],
      "credentials"=>{
        "url"=>url}
    }
    end

    def create_service(name, type, version)
      {"name"=>"#{name}",
      "label"=>"#{type}-#{version}",
      "plan"=>"free",
      "tags"=>["#{type}","#{type}-#{version}"],
      "credentials"=>{
        "hostname"=>"#{SOME_SERVER}",
        "host"=>"#{SOME_SERVER}",
        "port"=> SOME_SERVICE_PORT,
        "username"=>"#{secure_uuid}",
        "password"=>"#{secure_uuid}",
        "name"=>"#{secure_uuid}"}
      }
    end
  end
end
