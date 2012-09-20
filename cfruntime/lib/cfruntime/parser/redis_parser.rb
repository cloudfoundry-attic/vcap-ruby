module CFRuntime
  class RedisParser
    def self.parse(svc)
      serviceopts = {}
      { :username => :username,
        :password => :password,
        :hostname => :host,
        :port => :port,
        :name => :database
      }.each do |from, to|
        serviceopts[to] = svc["credentials"][from.to_s]
      end
      serviceopts[:url] = svc["credentials"]["url"] ||
        "redis://#{serviceopts[:username]}:#{serviceopts[:password]}@" +
        "#{serviceopts[:host]}:#{serviceopts[:port]}/#{serviceopts[:database]}"
      serviceopts
    end
  end
end
