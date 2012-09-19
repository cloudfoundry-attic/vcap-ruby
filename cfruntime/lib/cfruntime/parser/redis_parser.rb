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
      serviceopts
    end
  end
end
