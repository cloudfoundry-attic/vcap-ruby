require File.join(File.dirname(__FILE__), '../../','spec_helper')
require 'aws/s3'
require 'cf-autoconfig/blob/aws_s3_configurer'

describe 'AutoReconfiguration::AwsS3' do

  before(:each) do
    ENV['VCAP_SERVICES'] = '{"blob-1.0":[{"name": "blob-1","label": "blob-1.0",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40","port": 12345, ' +
      '"username": "8d93ae0a", "password": "7cf3c0e3"}}]}'
    ENV['DISABLE_AUTO_CONFIG'] = nil
  end

  it 'auto-configures AwsS3 on connect' do
    AWS::S3::Base.establish_connection!(
      :access_key_id      => "myid",
      :secret_access_key  => "mykey"
    )
    AWS::S3::Base.connection.options.should == {:server=>"10.20.30.40",
      :port=>12345, :access_key_id=>"8d93ae0a", :secret_access_key=>"7cf3c0e3"}
  end

  it 'auto-configures AwsS3 on connect with server and port' do
    AWS::S3::Base.establish_connection!(
      :access_key_id      => "myid",
      :secret_access_key  => "mykey",
      :server             => "myserver.com",
      :port               =>  10001
    )
    AWS::S3::Base.connection.options.should == {:server=>"10.20.30.40",
      :port=>12345, :access_key_id=>"8d93ae0a", :secret_access_key=>"7cf3c0e3"}
  end

  it 'does not auto-configure Blob if VCAP_SERVICES not set' do
    ENV['VCAP_SERVICES'] = nil
    AWS::S3::Base.establish_connection!(
      :access_key_id      => "myid",
      :secret_access_key  => "mykey",
      :server             => "myserver.com",
      :port               =>  10001
    )
    AWS::S3::Base.connection.options.should == {:server=>"myserver.com",
      :port=>10001, :access_key_id=>"myid", :secret_access_key=>"mykey"}
  end

  it 'does not auto-configure Blob if multiple Blob services found' do
    ENV['VCAP_SERVICES'] = '{"blob-1.0":[{"name": "blob-1","label": "blob-1.0",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.40","port": 12345, ' +
      '"username": "8d93ae0a", "password": "7cf3c0e3"}},
      {"name": "blob-2","label": "blob-1.0",' +
      '"plan": "free", "credentials": {"hostname": "10.20.30.44","port": 1245, ' +
      '"username": "8d93ae0a", "password": "7cf3c0e3"}}]}'
      AWS::S3::Base.establish_connection!(
        :access_key_id      => "myid",
        :secret_access_key  => "mykey",
        :server             => "myserver.com",
        :port               =>  10001
      )
      AWS::S3::Base.connection.options.should == {:server=>"myserver.com",
        :port=>10001, :access_key_id=>"myid", :secret_access_key=>"mykey"}
  end

  it 'does not open Connection class to apply methods twice' do
    load 'cf-autoconfig/blob/aws_s3_configurer.rb'
    #This would blow up massively (stack trace too deep) if we
    #aliased connect twice
    AWS::S3::Base.establish_connection!(
      :access_key_id      => "myid",
      :secret_access_key  => "mykey"
    )
    AWS::S3::Base.connection.options.should == {:server=>"10.20.30.40",
      :port=>12345, :access_key_id=>"8d93ae0a", :secret_access_key=>"7cf3c0e3"}
   end

  it 'disables Blob auto-reconfig if DISABLE_AUTO_CONFIG includes blob' do
    ENV['DISABLE_AUTO_CONFIG'] = "redis:blob:mongodb"
    load 'cf-autoconfig/blob/aws_s3_configurer.rb'
    AWS::S3::Base.establish_connection!(
      :access_key_id      => "myid",
      :secret_access_key  => "mykey",
      :server             => "myserver.com",
      :port               =>  10001
    )
    AWS::S3::Base.connection.options.should == {:server=>"myserver.com",
      :port=>10001, :access_key_id=>"myid", :secret_access_key=>"mykey"}
  end
end
