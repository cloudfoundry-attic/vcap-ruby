module CFRuntime
  class MongodbParser
    def self.parse(svc)
      serviceopts = {}
      { :username => :username,
        :password => :password,
        :host => :host,
        :port => :port,
        :db => :db
      }.each do |from, to|
        serviceopts[to] = svc["credentials"][from.to_s]
      end
      serviceopts
    end
  end
end
