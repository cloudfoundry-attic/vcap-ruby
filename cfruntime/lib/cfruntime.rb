begin
  require 'cfruntime/amqp'
rescue LoadError
end
begin
  require 'cfruntime/carrot'
rescue LoadError
end
begin
  require 'cfruntime/mongodb'
rescue LoadError
end
begin
  require 'cfruntime/mysql'
rescue LoadError
end
begin
  require 'cfruntime/postgres'
rescue LoadError
end
begin
  require 'cfruntime/redis'
rescue LoadError
end
require 'cfruntime/properties'
require 'cfruntime/version'