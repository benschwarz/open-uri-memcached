require 'openuri/common'

module OpenURI
  class Cache
    class << self
      # Enable caching
      def enable!
        @cache ||= Rails.cache
        @cache_enabled = true
      end
      
      def get(key)
        @cache.read(key)
      end
      
      def set(key, value)
        @cache.write(key, value, :expires_in => expiry)
      end
    end
  end
end