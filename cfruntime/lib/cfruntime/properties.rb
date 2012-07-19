module CFRuntime

  require 'uri'
  require File.join(File.dirname(__FILE__), 'okjson')

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
        if ENV['VCAP_SERVICES']
          svcs = CFRuntime::OkJson.decode(ENV['VCAP_SERVICES'])
        else
          svcs = {}
        end
        svcs.each do |key,list|
          label, version = key.split('-')
          list.each do |svc|
            name = svc["name"]
            serviceopts = {}
            serviceopts[:label] = label
            serviceopts[:version] = version
            serviceopts[:name] = name
            cred = svc["credentials"]
            if label =~ /rabbitmq/
              if cred['url']
                #The RabbitMQ default vhost
                vhost = '/'
                # The new "srs" credentials format
                uri=URI.parse(cred['url'])
                user=URI.unescape(uri.user) if uri.user
                passwd=URI.unescape(uri.password) if uri.password
                host=uri.host
                port=uri.port
                if uri.path =~ %r{^/(.*)}
                  raise ArgumentError.new("multiple segments in path of amqp URI: #{uri}") if $1.index('/')
                  vhost = URI.unescape($1)
                end
                serviceopts[:url] = cred['url']
              else
                # The "old" credentials format
                user,passwd,host,port,vhost = %w(user pass hostname port vhost).map {|key|
                  cred[key]}
              end
              serviceopts[:vhost] = vhost
            else
              user,passwd,host,port,dbname,db = %w(username password hostname port name db).map {|key|
                cred[key]}
              if label == "mongodb"
                serviceopts[:db] = db
              else
                serviceopts[:database] = dbname
              end
            end
            serviceopts[:username] = user
            serviceopts[:password] = passwd
            serviceopts[:host] = host
            serviceopts[:port] = port
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
