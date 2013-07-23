require 'cf-runtime/properties'

if CFRuntime::CloudApp.service_props('redis')
  puts "Loading Redis auto-reconfiguration."
  require 'cf-autoconfig/keyvalue/redis_configurer'
end

if CFRuntime::CloudApp.service_props('memcached')
  puts "Loading Memcached auto-reconfiguration."
  require 'cf-autoconfig/keyvalue/dalli_configurer'
end

if CFRuntime::CloudApp.service_props('mongodb')
  puts "Loading MongoDB auto-reconfiguration."
  require 'cf-autoconfig/document/mongodb_configurer'
end

if CFRuntime::CloudApp.service_props('mysql')
  puts "Loading MySQL auto-reconfiguration."
  require 'cf-autoconfig/relational/mysql_configurer'
end

if CFRuntime::CloudApp.service_props('postgresql')
  puts "Loading PostgreSQL auto-reconfiguration."
  require 'cf-autoconfig/relational/postgres_configurer'
end

if CFRuntime::CloudApp.service_props('rabbitmq')
  puts "Loading RabbitMQ auto-reconfiguration."
  require 'cf-autoconfig/messaging/amqp_configurer'
  require 'cf-autoconfig/messaging/carrot_configurer'
end

if CFRuntime::CloudApp.service_props('blob')
  puts "Loading Blob auto-reconfiguration."
  require 'cf-autoconfig/blob/aws_s3_configurer'
end
