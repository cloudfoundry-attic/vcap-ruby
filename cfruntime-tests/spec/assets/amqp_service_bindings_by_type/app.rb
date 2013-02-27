require 'sinatra'
require 'json/pure'
require 'uri'
require 'amqp'
require 'cf-runtime'

get '/env' do
  ENV['VMC_SERVICES']
end

get '/' do
  'hello from sinatra'
end

not_found do
  'This is nowhere to be found.'
end

post '/service/amqp/:key' do
  value = request.env["rack.input"].read
  write_to_rabbit(params[:key], value)
end

get '/service/amqp/:key' do
  options.amqp_option_msg
end

def write_to_rabbit(key, value)
  EventMachine.run do
    connection = CFRuntime::AMQPClient.create
    channel  = AMQP::Channel.new(connection)
    queue    = channel.queue(key, :auto_delete => true)
    exchange = channel.default_exchange
    queue.subscribe do |payload|
      puts "Received a message: #{payload}. Disconnecting..."
      set :amqp_option_msg, payload
      connection.close { EventMachine.stop }
    end
    exchange.publish value, :routing_key => queue.name, :app_id => "Hello world"
  end
end
