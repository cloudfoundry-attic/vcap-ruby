module CFRuntime
  class PostgresqlParser
    def self.parse(svc)
      serviceopts = {}
      serviceopts[:username],serviceopts[:password],serviceopts[:host],
        serviceopts[:port],serviceopts[:database] =
        %w(username password hostname port name).map {|key| svc["credentials"][key]}
      serviceopts
    end
  end
end
