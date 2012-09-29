require 'spec_helper'
require 'cfruntime/aws_s3'

describe 'CFRuntime::AWSS3Client' do

  after(:each) do
    AWS::S3::Base.disconnect!
  end

  it 'creates a client with a Blob service by type and no additional options' do
    svcs = {"blob-#{blob_version}"=>[create_blob_service('blob-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::AWSS3Client.create
      client.options.should=={:access_key_id=>"testuser",:secret_access_key=>"testpw", :server=>SOME_SERVER, :port=>SOME_SERVICE_PORT}
    end
  end

  it 'creates a client with a Blob service by type and additional options' do
    svcs = {"blob-#{blob_version}"=>[create_blob_service('blob-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::AWSS3Client.create({:use_ssl=>"true"})
      client.options.should=={:access_key_id=>"testuser",:secret_access_key=>"testpw",
        :server=>SOME_SERVER, :port=>SOME_SERVICE_PORT, :use_ssl=>"true"}
    end
  end

  it 'creates a client with a Blob service by name and no additional options' do
    svcs = {"blob-#{blob_version}"=>[create_blob_service('blob-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::AWSS3Client.create_from_svc('blob-test')
      client.options.should=={:access_key_id=>"testuser",:secret_access_key=>"testpw",
        :server=>SOME_SERVER, :port=>SOME_SERVICE_PORT}
    end
  end

  it 'creates a client with a Blob service by name and additional options' do
    svcs = {"blob-#{blob_version}"=>[create_blob_service('blob-test')]}
    with_vcap_services(svcs) do
      client = CFRuntime::AWSS3Client.create_from_svc('blob-test', {:use_ssl=>"true"})
      client.options.should=={:access_key_id=>"testuser",:secret_access_key=>"testpw",
        :server=>SOME_SERVER, :port=>SOME_SERVICE_PORT, :use_ssl=>"true"}
    end
  end

  it 'raises an ArgumentError if no service of Blob type found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::AWSS3Client.create}.to raise_error(ArgumentError,
      'Expected 1 service of blob type, but found 0.  Consider using create_from_svc(service_name) instead.')
  end

  it 'raises an ArgumentError if multiple services of Blob type found' do
    svcs = {"blob-#{blob_version}"=>[create_blob_service('blob-test'),
        create_blob_service('blob-test2')]}
    with_vcap_services(svcs) do
      expect{CFRuntime::AWSS3Client.create}.to raise_error(ArgumentError,
        'Expected 1 service of blob type, but found 2.  Consider using create_from_svc(service_name) instead.')
    end
  end

  it 'raises an ArgumentError if Blob service of specified name is not found' do
    ENV['VCAP_SERVICES'] = nil
    expect{CFRuntime::AWSS3Client.create_from_svc('non-existent-blob')}.to raise_error(ArgumentError,
      'Service with name non-existent-blob not found')
  end
end