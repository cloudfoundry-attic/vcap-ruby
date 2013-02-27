module CFRuntime
  class MongodbParser
    def self.parse(svc)
      serviceopts = {}
      cred = svc["credentials"]
      if cred["url"]
        uri=URI.parse(cred["url"])
        user=URI.unescape(uri.user) if uri.user
        passwd=URI.unescape(uri.password) if uri.password
        host=uri.host
        port=uri.port
        if uri.path =~ %r{^/(.*)}
          raise ArgumentError.new("multiple segments in path of mongo URI: #{uri}") if $1.index('/')
          db = URI.unescape($1)
        end
        url = cred["url"]
      else
        # The old credentials format with no URL
        user,passwd,host,port, db = %w(username password hostname port db).map {|key|
          cred[key]}
        url = "mongodb://#{user}:#{passwd}@#{host}:#{port}/#{db}"
      end
      serviceopts[:username] = user
      serviceopts[:password] = passwd
      serviceopts[:host] = host
      serviceopts[:port] = port
      serviceopts[:url] = url
      serviceopts[:db] = db
      serviceopts
    end
  end
end
