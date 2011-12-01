File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'amqp'
require 'cfautoconfig/messaging/amqp_configurer'

describe 'AutoReconfiguration::AMQP' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"url": "amqp://username:password@10.20.30.40:12345/virtualHost"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
    load 'cfruntime/properties.rb'
    @mock_connection = mock("connection")
  end

  it 'auto-configures AMQP on connect with options and new format (srs)' do
    mock_client = mock("client")
    AMQP.client = mock_client
    mock_client.should_receive(:connect).with({:host => '10.20.30.40', :port =>12345, :user=>'username',
      :pass=>'password', :vhost=>'virtualHost'}).and_return(@mock_connection)
    @mock_connection.should_receive(:on_open)
    AMQP.connect({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
  end

  it 'auto-configures AMQP on connect with options and old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    load 'cfruntime/properties.rb'
    mock_client = mock("client")
    AMQP.client = mock_client
    mock_client.should_receive(:connect).with({:host => '10.20.30.40', :port =>12345, :user=>'username',
      :pass=>'password', :vhost=>'virtualHost'}).and_return(@mock_connection)
    @mock_connection.should_receive(:on_open)
    AMQP.connect({:host => '127.0.0.1', :port =>1234, :user=>'testuser',
      :pass=>'testpass', :vhost=>'testvhost'})
  end

  it 'auto-configures AMQP on connect with url and new format (srs)' do
    mock_client = mock("client")
    AMQP.client = mock_client
    mock_client.should_receive(:connect).with(:scheme=>"amqp", :user=>"username", :pass=>"password",
      :host=>"10.20.30.40", :port=>12345, :ssl=>false, :vhost=>"virtualHost").and_return(@mock_connection)
    @mock_connection.should_receive(:on_open)
    AMQP.connect("amqp://testuser:testpass@127.0.0.1:1234/testvhost")
  end

  it 'auto-configures AMQP on connect with url and old format' do
    ENV['VCAP_SERVICES'] = '{"rabbitmq-2.4":[{"name": "rabbit-1","label": "rabbitmq-2.4",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40", "port": 12345, "user": "username",
      "pass":"password", "vhost" : "virtualHost"}}]}'
    load 'cfruntime/properties.rb'
    mock_client = mock("client")
    AMQP.client = mock_client
    mock_client.should_receive(:connect).with({:host => '10.20.30.40', :port =>12345, :user=>'username',
      :pass=>'password', :vhost=>'virtualHost'}).and_return(@mock_connection)
    @mock_connection.should_receive(:on_open)
    AMQP.connect("amqp://testuser:testpass@127.0.0.1:1234/testvhost")
  end

  it 'does not auto-configure AMQP if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    load 'cfruntime/properties.rb'
    mock_client = mock("client")
    AMQP.client = mock_client
    mock_client.should_receive(:connect).with(:scheme=>"amqp", :user=>"testuser", :pass=>"testpass",
      :host=>"127.0.0.1", :port=>1234, :ssl=>false, :vhost=>"testvhost").and_return(@mock_connection)
    @mock_connection.should_receive(:on_open)
    AMQP.connect("amqp://testuser:testpass@127.0.0.1:1234/testvhost")
  end

  it 'does not open AMQP class to apply methods twice' do
     load 'cfautoconfig/messaging/amqp_configurer.rb'
     #This would blow up massively (stack trace too deep) if we
     #aliased the connect methods twice
     mock_client = mock("client")
     AMQP.client = mock_client
     mock_client.should_receive(:connect).with(:scheme=>"amqp", :user=>"username", :pass=>"password",
       :host=>"10.20.30.40", :port=>12345, :ssl=>false, :vhost=>"virtualHost").and_return(@mock_connection)
     @mock_connection.should_receive(:on_open)
     AMQP.connect("amqp://testuser:testpass@127.0.0.1:1234/testvhost")
   end

  it 'disables AMQP auto-reconfig if DISABLE_AUTO_CONFIG includes rabbitmq' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:rabbitmq:mongodb"
    load 'cfautoconfig/messaging/amqp_configurer.rb'
    mock_client = mock("client")
    AMQP.client = mock_client
    mock_client.should_receive(:connect).with(:scheme=>"amqp", :user=>"testuser", :pass=>"testpass",
      :host=>"127.0.0.1", :port=>1234, :ssl=>false, :vhost=>"testvhost").and_return(@mock_connection)
    @mock_connection.should_receive(:on_open)
    AMQP.connect("amqp://testuser:testpass@127.0.0.1:1234/testvhost")
  end

end