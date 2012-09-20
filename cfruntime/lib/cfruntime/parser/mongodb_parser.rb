module CFRuntime
  class MongodbParser
    def self.parse(svc)
      serviceopts = {}
      { :username => :username,
        :password => :password,
        :hostname => :host,
        :port => :port,
        :db => :db
      }.each do |from, to|
        serviceopts[to] = svc["credentials"][from.to_s]
      end
      serviceopts[:url] = svc["credentials"]["url"] ||
        "mongodb://#{serviceopts[:username]}:#{serviceopts[:password]}@" +
        "#{serviceopts[:host]}:#{serviceopts[:port]}/#{serviceopts[:db]}"
      serviceopts
    end
  end
end
