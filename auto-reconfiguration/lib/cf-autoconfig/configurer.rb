require 'cf-runtime/properties'

if CFRuntime::CloudApp.service_props('redis')
  puts "Loading Redis auto-reconfiguration."
  require 'cf-autoconfig/keyvalue/redis_configurer'
else
  puts "No Redis service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('mongodb')
  puts "Loading MongoDB auto-reconfiguration."
  require 'cf-autoconfig/document/mongodb_configurer'
else
  puts "No Mongo service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('mysql')
  puts "Loading MySQL auto-reconfiguration."
  require 'cf-autoconfig/relational/mysql_configurer'
else
  puts "No MySQL service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('postgresql')
  puts "Loading PostgreSQL auto-reconfiguration."
  require 'cf-autoconfig/relational/postgres_configurer'
else
  puts "No PostgreSQL service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('rabbitmq')
  puts "Loading RabbitMQ auto-reconfiguration."
  require 'cf-autoconfig/messaging/amqp_configurer'
  require 'cf-autoconfig/messaging/carrot_configurer'
else
  puts "No RabbitMQ service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('blob')
  puts "Loading Blob auto-reconfiguration."
  require 'cf-autoconfig/blob/aws_s3_configurer'
else
  puts "No Blob service bound to app.  Skipping auto-reconfiguration."
end
