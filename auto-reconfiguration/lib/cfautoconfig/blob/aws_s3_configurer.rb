require 'cfautoconfig/configuration_helper'
begin
  require 'aws/s3'
  require File.join(File.dirname(__FILE__), 'aws_s3')
  aws_s3_version = Gem.loaded_specs['aws-s3'].version
  if aws_s3_version >= Gem::Version.new(AutoReconfiguration::SUPPORTED_AWS_S3_VERSION)
    if AutoReconfiguration::ConfigurationHelper.disabled? :blob
      puts "Blob auto-reconfiguration disabled."
      module AWS
        module S3
          class << Connection
            #Remove introduced aliases and methods.
            #This is mostly for testing, as we don't expect this script
            #to run twice during a single app startup
            if method_defined?(:connect_with_cf)
              undef_method :connect_with_cf
              alias :connect :original_connect
            end
          end
        end
      end
    elsif AWS::S3::Connection.public_methods.index :connect_with_cf
      #Guard against introducing a method that may already exist
      puts "AWS-S3 auto-reconfiguration already included."
    else
      #Introduce around alias into Redis class
      module AWS
        module S3
          class << Connection
            include AutoReconfiguration::AwsS3
          end
        end
      end
    end
  else
    puts "Auto-reconfiguration not supported for this AWS-S3 version.  " +
      "Found: #{aws_s3_version}.  Required: #{AutoReconfiguration::SUPPORTED_AWS_S3_VERSION} or higher."
  end
rescue LoadError=>e
  puts "No AWS-S3 Library Found. Skipping auto-reconfiguration. #{e}"
end
