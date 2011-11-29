# Copyright (c) 2009-2011 VMware, Inc.

module CFRuntime
  
  require 'json/pure'  

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
          dbopts = {}
          cred = svc["credentials"]
          user,passwd,host,port,dbname,db = %w(username password hostname port name db).map {|key|
            cred[key]}
          dbopts[:label] = label
          dbopts[:version] = version
          dbopts[:name] = name
          dbopts[:username] = user
          dbopts[:password] = passwd
          dbopts[:host] = host
          dbopts[:port] = port
          if label == "mongodb"
            dbopts[:db] = db
          else
            dbopts[:database] = dbname
          end
          @@svcs[name] = dbopts
          @@svc_names << name
          if count == 1
            @@svcs[label] = dbopts
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
