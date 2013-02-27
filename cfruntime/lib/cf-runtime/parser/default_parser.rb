module CFRuntime
  class DefaultParser
    # Default parsing behavior simply returns
    # the passed-in map with all keys converted
    # to symbols
    def self.parse(svc)
      symbolize_keys(svc)
    end

    private
    def self.symbolize_keys(hash)
      if hash.is_a? Hash
        new_hash = {}
        hash.each {|k, v| new_hash[k.to_sym] = symbolize_keys(v) }
        new_hash
      else
        hash
      end
    end
  end
end