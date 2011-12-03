require 'cfruntime/properties'

if CFRuntime::CloudApp.service_props('redis')
  puts "Loading Redis auto-reconfiguration."
  require 'cfautoconfig/keyvalue/redis_configurer'
else
  puts "No Redis service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('mongodb')
  puts "Loading MongoDB auto-reconfiguration."
  require 'cfautoconfig/document/mongodb_configurer'
else
  puts "No Mongo service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('mysql')
  puts "Loading MySQL auto-reconfiguration."
  require 'cfautoconfig/relational/mysql_configurer'
else
  puts "No MySQL service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('postgresql')
  puts "Loading PostgreSQL auto-reconfiguration."
  require 'cfautoconfig/relational/postgres_configurer'
else
  puts "No PostgreSQL service bound to app.  Skipping auto-reconfiguration."
end

if CFRuntime::CloudApp.service_props('rabbitmq')
  puts "Loading RabbitMQ auto-reconfiguration."
  require 'cfautoconfig/messaging/amqp_configurer'
  require 'cfautoconfig/messaging/carrot_configurer'
else
  puts "No RabbitMQ service bound to app.  Skipping auto-reconfiguration."
end