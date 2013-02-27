require 'aws/s3'
require 'cf-runtime/properties'
module CFRuntime
  class AWSS3Client

    # Creates and returns an AWS-S3 +Client+ instance.
    # Passes optional Hash of non-connection-related options to +AWS::S3::Base.establish_connection!+.
    # Raises +ArgumentError+ If zero or multiple blob services are found.
    def self.create(options={})
      service_names = CloudApp.service_names_of_type('blob')
      if service_names.length != 1
        raise ArgumentError.new("Expected 1 service of blob type, " +
          "but found #{service_names.length}.  " +
          "Consider using create_from_svc(service_name) instead.")
      end
      create_from_svc(service_names[0],options)
    end

    # Creates and returns a AWS-S3 +Client+ instance connected to a blob service with the
    # specified name.
    # Passes optional Hash of non-connection-related options to +AWS::S3::Base.establish_connection!+.
    # Raises +ArgumentError+ If specified blob service is not found.
    def self.create_from_svc(service_name, options={})
      AWS::S3::Base.establish_connection!(options_for_svc(service_name,options))
    end

    # Merges provided options with connection options for specified blob service.
    # Returns merged Hash containing (:access_key_id, :secret_access_key, :server, :port).
    # Raises +ArgumentError+ If specified blob service is not found.
    def self.options_for_svc(service_name,options={})
      service_props = CFRuntime::CloudApp.service_props(service_name)
      if service_props.nil?
        raise ArgumentError.new("Service with name #{service_name} not found")
      end
      cfoptions = options
      cfoptions[:server] = service_props[:host]
      cfoptions[:port] = service_props[:port]
      cfoptions[:access_key_id ] = service_props[:username]
      cfoptions[:secret_access_key] = service_props[:password]
      cfoptions
    end
  end
end
