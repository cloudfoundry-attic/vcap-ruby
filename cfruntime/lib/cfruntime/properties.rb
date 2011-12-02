# Copyright (c) 2009-2011 VMware, Inc.

module CFRuntime

  require 'json/pure'
  require 'uri'

  class CloudApp

    class << self
      def running_in_cloud?()
        !ENV['VCAP_APPLICATION'].nil?
      end

      def host
        ENV['VCAP_APP_HOST']
      end

      def port
        ENV['VCAP_APP_PORT']
      end

      def service_props(service_name)
        return @svcs[service_name] if @svcs and @svcs.key? service_name
        @svcs = {}
        svcs = JSON.parse(ENV['VCAP_SERVICES'])
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
            @svcs[name] = serviceopts
            if list.count == 1
              @svcs[label] = serviceopts
            end
          end
        end
        @svcs[service_name]
      end

      def service_names
        service_names = []
        JSON.parse(ENV['VCAP_SERVICES']).each do |key,list|
          list.each do |svc|
            service_names << svc["name"]
          end
        end
        service_names
      end
    end

  end

end
