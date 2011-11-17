module AutoReconfiguration
  class ConfigurationHelper
    def self.disabled? (client)
      disable_auto_config = []
      if ENV['DISABLE_AUTO_CONFIG']
        disable_auto_config = ENV['DISABLE_AUTO_CONFIG'].split(/\s*\:\s*/)
        disable_auto_config.collect! { |element|
          element.upcase
        }
      end
      if disable_auto_config.include? 'ALL'
        true
      else
        disable_auto_config.include? client.to_s.upcase
      end
    end
  end
end
     