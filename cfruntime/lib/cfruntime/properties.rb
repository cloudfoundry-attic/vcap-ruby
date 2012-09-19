require "uri"
require "cfruntime/okjson"
require "cfruntime/parser"

module CFRuntime
  class CloudApp
    class << self
      # Returns true if this code is running on Cloud Foundry
      def running_in_cloud?()
        !ENV['VCAP_APPLICATION'].nil?
      end

      # Returns the application host name
      def host
        ENV['VCAP_APP_HOST']
      end

      # Returns the port bound to the application
      def port
        ENV['VCAP_APP_PORT']
      end

      # Parses the VCAP_SERVICES environment variable and returns a Hash of properties
      # for the specified service name.  If only one service of a particular type is bound
      # to the application, service_props(type) will also work.
      # Example: service_props('mysql').
      # Returns nil if service with specified name is not found or if zero or multiple services
      # of a specified type are found.
      def service_props(service_name)
        registered_svcs = {}
        svcs = ENV['VCAP_SERVICES'] ? CFRuntime::OkJson.decode(ENV['VCAP_SERVICES']) : {}
        svcs.each do |key,list|
          label, version = key.split('-')
          begin
            parser = Object.const_get("CFRuntime").const_get("#{label.capitalize}Parser")
          rescue NameError
            parser = Object.const_get("CFRuntime").const_get("DefaultParser")
          end
          list.each do |svc|
            name = svc["name"]
            serviceopts = {}
            serviceopts[:label] = label
            serviceopts[:version] = version
            serviceopts[:name] = name
            serviceopts.merge!(parser.parse(svc))
            registered_svcs[name] = serviceopts
            if list.count == 1
              registered_svcs[label] = serviceopts
            end
          end
        end
        registered_svcs[service_name]
      end

      # Parses the VCAP_SERVICES environment variable and returns an array of Service
      # names bound to the current application.
      def service_names
        service_names = []
        if ENV['VCAP_SERVICES']
          CFRuntime::OkJson.decode(ENV['VCAP_SERVICES']).each do |key,list|
            list.each do |svc|
              service_names << svc["name"]
            end
          end
        end
        service_names
      end

      # Parses the VCAP_SERVICES environment variable and returns an array of Service
      # names of the specified type bound to the current application.
      # Example: service_names_of_type('mysql')
      def service_names_of_type(type)
        service_names = []
        if ENV['VCAP_SERVICES']
          CFRuntime::OkJson.decode(ENV['VCAP_SERVICES']).each do |key,list|
            label, version = key.split('-')
            list.each do |svc|
              if label == type
                service_names << svc["name"]
              end
            end
          end
        end
        service_names
      end
    end
  end
end