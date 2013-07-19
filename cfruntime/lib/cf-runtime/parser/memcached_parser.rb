module CFRuntime
  class MemcachedParser
    def self.parse(svc)
      serviceopts = {}
      { :user => :username,
        :password => :password,
        :hostname => :host,
        :port => :port
      }.each do |from, to|
        serviceopts[to] = svc["credentials"][from.to_s]
      end
      serviceopts[:url] = svc["credentials"]["url"] ||
        "memcached://#{serviceopts[:username]}:#{serviceopts[:password]}@" +
        "#{serviceopts[:host]}:#{serviceopts[:port]}/"
      serviceopts
    end
  end
end
