# Copyright (c) 2009-2011 VMware, Inc.

module CFRuntime

  require 'json/pure'
  require 'uri'

  class CloudApp

    @@app = ENV['VCAP_APPLICATION']
    @@host = ENV['VCAP_APP_HOST']
    @@port = ENV['VCAP_APP_PORT']
    @@svcs = {}
    @@svc_names = []

    vcapsvcs = ENV['VCAP_SERVICES']

    if vcapsvcs
      svcs = JSON.parse(ENV['VCAP_SERVICES'])
      svcs.each do |key,list|
        count = list.count
        label = key[0..key.index('-')-1]
        version = key[key.index('-')+1..key.length]
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
          @@svcs[name] = serviceopts
          @@svc_names << name
          if count == 1
            @@svcs[label] = serviceopts
          end
        end
      end
    end

    def self.service_names()
      @@svc_names
    end

    def self.service_props(name)
      @@svcs[name]
    end

    def self.host()
      @@host
    end

    def self.port()
      @@port
    end

    def self.running_in_cloud?()
      if @@app == nil
        false
      else
        true
      end
    end

  end

end
