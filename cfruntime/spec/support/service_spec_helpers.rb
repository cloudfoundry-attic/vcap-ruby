# Ruby 1.8.7 seems to require that these constants be defined outside the module
# in order for RSpec tests to see them
SOME_SERVER = '172.30.48.73'
SOME_PORT = 56789
SOME_SERVICE_PORT = 25046

module ServiceSpecHelpers

  def with_vcap_application
    vcap_app = '{"instance_id":"testid",
      "instance_index": 0,
      "name":"tr_env",
      "uris":["tr_env.cloudfoundry.com"],
      "users":["trisberg@vmware.com"],
      "version":"1.0",
      "start":"2011-11-05 13:29:32 +0000",
      "runtime":"ruby19",
      "state_timestamp":1320499772,
      "port":SOME_PORT,
      "limits":{"fds":256,"mem":134217728,"disk":2147483648},
      "host":"#{SOME_SERVER}"}'
    ENV['VCAP_APPLICATION'] = vcap_app
    ENV['VCAP_APP_HOST'] = SOME_SERVER
    ENV['VCAP_APP_PORT'] = "#{SOME_PORT}"
    yield
  end

  def with_vcap_services(services)
    vcap_svcs = '{'
    services.each {|type, svcs|
      vcap_svcs = vcap_svcs + '"' + type + '":['
        svcs.each do |svc|
          vcap_svcs = vcap_svcs + svc + ','
        end
        vcap_svcs.chomp!(',')
      vcap_svcs = vcap_svcs + '],'
    }
    vcap_svcs.chomp!(',')
    vcap_svcs = vcap_svcs + '}'
    ENV['VCAP_SERVICES'] = vcap_svcs
    yield
  end

  def mongo_version
    "1.8"
  end

  def redis_version
    "2.2"
  end

  def memcached_version
    "1.4"
  end

  def rabbit_version
    "2.4"
  end

  def mysql_version
    "0.3.11"
  end

  def postgres_version
    "0.11.0"
  end

  def blob_version
    "0.5.1"
  end

  def create_mongo_service(name, url=false)
    svc = "{\"name\":\"#{name}\",\"label\":\"mongodb-#{mongo_version}\",\"plan\":\"free\"," +
      "\"tags\":[\"mongodb\",\"mongodb-#{mongo_version}\"],\"credentials\":{\"hostname\":\"#{SOME_SERVER}\"," +
      "\"host\":\"#{SOME_SERVER}\",\"port\":#{SOME_SERVICE_PORT},\"username\":\"testuser\",\"password\":\"testpw\"," +
      "\"db\":\"db\""
    svc = svc + ", \"url\":\"mongodb://testuser:testpw@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/db\"" if url
    svc = svc + "}}"
    svc
  end

  def create_blob_service(name)
    svc = "{\"name\":\"#{name}\",\"label\":\"blob-#{blob_version}\",\"plan\":\"free\"," +
      "\"credentials\":{\"hostname\":\"#{SOME_SERVER}\"," +
      "\"host\":\"#{SOME_SERVER}\",\"port\":#{SOME_SERVICE_PORT},\"username\":\"testuser\",\"password\":\"testpw\"" +
      "}}"
  end

  def create_redis_service(name)
    create_service(name, "redis", redis_version, "redisdata")
  end

  def create_memcached_service(name)
    svc = "{\"name\":\"#{name}\",\"label\":\"memcached-#{memcached_version}\",\"plan\":\"100\"," +
      "\"credentials\":{\"hostname\":\"#{SOME_SERVER}\"," +
      "\"host\":\"#{SOME_SERVER}\",\"port\":#{SOME_SERVICE_PORT},\"user\":\"testuser\",\"password\":\"testpw\"" +
      "}}"
  end

  def create_mysql_service(name)
    create_service(name, "mysql", mysql_version,"mysqldatabase")
  end

  def create_postgres_service(name)
    create_service(name, "postgresql", postgres_version,"pgdatabase")
  end

  def create_rabbit_service(name, vhost=nil)
    svc = "{\"name\":\"#{name}\",\"label\":\"rabbitmq-#{rabbit_version}\"," +
    "\"plan\":\"free\",\"tags\":[\"rabbitmq\",\"rabbitmq-#{rabbit_version}\"]," +
    "\"credentials\":{\"hostname\":\"#{SOME_SERVER}\",\"port\":#{SOME_SERVICE_PORT},\"user\":\"rabbituser\"," +
    "\"pass\":\"rabbitpass\""
    svc = svc + ",\"vhost\":\"#{vhost}\""  if vhost
    svc = svc + "}}"
    svc
  end

  def create_rabbit_srs_service(name, vhost=nil)
    if vhost
      url = "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}/#{vhost}"
    else
      url = "amqp://rabbituser:rabbitpass@#{SOME_SERVER}:#{SOME_SERVICE_PORT}"
    end
    "{\"name\":\"#{name}\",\"label\":\"rabbitmq-#{rabbit_version}\"," +
    "\"plan\":\"free\",\"tags\":[\"rabbitmq\",\"rabbitmq-#{rabbit_version}\"]," +
    "\"credentials\":{\"url\":\"#{url}\"}}"
  end

  def create_service(name, type, version, cred_name)
    svc = "{\"name\":\"#{name}\",\"label\":\"#{type}-#{version}\",\"plan\":\"free\"," +
      "\"tags\":[\"#{type}\",\"#{type}-#{version}\"],\"credentials\":{\"hostname\":\"#{SOME_SERVER}\"," +
      "\"host\":\"#{SOME_SERVER}\",\"port\":#{SOME_SERVICE_PORT},\"username\":\"testuser\",\"password\":\"testpw\"," +
      "\"name\":\"#{cred_name}\"}}"
  end
end
