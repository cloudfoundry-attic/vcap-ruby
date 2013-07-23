require 'sinatra'
require 'redis'
require 'json'
require 'mongo'
require 'mysql2'
require 'carrot'
require 'uri'
require 'pg'
require 'cf-runtime'
require 'aws/s3'
require 'dalli'


get '/env' do
  ENV['VMC_SERVICES']
end

get '/' do
  'hello from sinatra'
end

get '/service/redis/:key' do
  redis = load_redis
  redis[params[:key]]
end

post '/service/redis/:key' do
  redis = load_redis
  redis[params[:key]] = request.env["rack.input"].read
end

get '/service/memcached/:key' do
  client = load_memcached
  client.get params[:key]
end

post '/service/memcached/:key' do
  value = request.env["rack.input"].read
  client = load_memcached
  client.set(params[:key], value)
  value
end

post '/service/mongo/:key' do
  coll = load_mongo
  value = request.env["rack.input"].read
  coll.insert( { '_id' => params[:key], 'data_value' => value } )
  value
end

get '/service/mongo/:key' do
  coll = load_mongo
  coll.find('_id' => params[:key]).to_a.first['data_value']
end

not_found do
  'This is nowhere to be found.'
end

post '/service/mysql/:key' do
  client = load_mysql
  value = request.env["rack.input"].read
  result = client.query("insert into data_values (id, data_value) values('#{params[:key]}','#{value}');")
  client.close
  value
end

get '/service/mysql/:key' do
  client = load_mysql
  result = client.query("select data_value from  data_values where id = '#{params[:key]}'")
  value = result.first['data_value']
  client.close
  value
end

post '/service/postgresql/:key' do
  client = load_postgresql
  value = request.env["rack.input"].read
  client.query("insert into data_values (id, data_value) values('#{params[:key]}','#{value}');")
  client.close
  value
end

get '/service/postgresql/:key' do
  client = load_postgresql
  value = client.query("select data_value from  data_values where id = '#{params[:key]}'").first['data_value']
  client.close
  value
end

post '/service/rabbit/:key' do
  value = request.env["rack.input"].read
  client = rabbit_service
  write_to_rabbit(params[:key], value, client)
  value
end

get '/service/rabbit/:key' do
  client = rabbit_service
  read_from_rabbit(params[:key], client)
end

post '/service/blob/:bucket' do
  load_blob
  AWS::S3::Bucket.create(params[:bucket])
end

get '/service/blob/:bucket' do
  load_blob
  AWS::S3::Bucket.find(params[:bucket]).inspect
end

post '/service/blob/:bucket/:object' do
  load_blob
  AWS::S3::S3Object.store(params[:object], request.body, params[:bucket])
end

get '/service/blob/:bucket/:object' do
  load_blob
  AWS::S3::S3Object.value(params[:object], params[:bucket])
end

def load_redis
  CFRuntime::RedisClient.create_from_svc('test-name-cfruntime-svc-test-redis')
end

def load_memcached
  CFRuntime::DalliClient.create_from_svc('test-name-cfruntime-svc-test-memcached')
end

def load_mysql
  client = CFRuntime::Mysql2Client.create_from_svc('test-name-cfruntime-svc-test-mysql')
  result = client.query("SELECT table_name FROM information_schema.tables WHERE table_name = 'data_values'");
  client.query("Create table IF NOT EXISTS data_values ( id varchar(20), data_value varchar(20)); ") if result.count != 1
  client
end

def load_mongo
  db = CFRuntime::MongoClient.create_from_svc('test-name-cfruntime-svc-test-mongo').db
  coll = db['data_values']
end

def load_postgresql
  client = CFRuntime::PGClient.create_from_svc('test-name-cfruntime-svc-test-postgresql')
  client.query("create table data_values (id varchar(20), data_value varchar(20));") if client.query("select * from information_schema.tables where table_name = 'data_values';").first.nil?
  client
end

def load_blob
  CFRuntime::AWSS3Client.create_from_svc('test-name-cfruntime-svc-test-blob')
end

def rabbit_service
  CFRuntime::CarrotClient.create_from_svc('test-name-cfruntime-svc-test-rabbit')
end

def write_to_rabbit(key, value, client)
  q = client.queue(key)
  q.publish(value)
end

def read_from_rabbit(key, client)
  q = client.queue(key)
  msg = q.pop(:ack => true)
  q.ack
  msg
end
