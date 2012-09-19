module CFRuntime
  class MongodbParser
    def self.parse(svc)
      serviceopts = {}
      serviceopts[:username],serviceopts[:password],serviceopts[:host],
        serviceopts[:port],serviceopts[:db] =
        %w(username password hostname port db).map {|key| svc["credentials"][key]}
      serviceopts
    end
  end
end
