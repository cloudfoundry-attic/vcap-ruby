require 'cfruntime/properties'
require 'cfruntime/aws_s3'

module AutoReconfiguration
  SUPPORTED_AWS_S3_VERSION = '0.6.3'
  module AwsS3
    def self.included( base )
      base.send(:alias_method, :original_connect, :connect)
      base.send(:alias_method, :connect, :connect_with_cf )
    end

    def connect_with_cf(options = {})
      service_names = CFRuntime::CloudApp.service_names_of_type('blob')
      if service_names.length == 1
        puts "Auto-reconfiguring AWS-S3"
        cfoptions = CFRuntime::AWSS3Client.options_for_svc(service_names[0],options)
        original_connect cfoptions
      else
        puts "Found #{service_names.length} blob services. Skipping auto-reconfiguration."
        original_connect options
      end
    end
  end
end