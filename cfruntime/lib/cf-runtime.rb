begin
  require 'cf-runtime/amqp'
rescue LoadError
end
begin
  require 'cf-runtime/carrot'
rescue LoadError
end
begin
  require 'cf-runtime/dalli'
rescue LoadError
end
begin
  require 'cf-runtime/mongodb'
rescue LoadError
end
begin
  require 'cf-runtime/mysql'
rescue LoadError
end
begin
  require 'cf-runtime/postgres'
rescue LoadError
end
begin
  require 'cf-runtime/redis'
rescue LoadError
end
begin
  require 'cf-runtime/aws_s3'
rescue LoadError
end
require 'cf-runtime/properties'
require 'cf-runtime/version'
