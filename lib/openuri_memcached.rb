require 'open-uri'
require 'rubygems'
require 'memcached'

module Kernel
  private 
  alias openuri_original_open open
  def open(uri, *rest, &block)
    OpenURI::open(uri, *rest, &block)
  end
  module_function :open, :openuri_original_open
end

module OpenURI
  alias original_open open #:nodoc:
  def self.open(uri, *rest, &block)
    if Cache.enabled?
      begin
        response = Cache::get(uri.to_s)
      rescue Memcached::NotFound
        response = false
      end
    end
    
    unless response
      response = openuri_original_open(uri, *rest, &block).read
      Cache::set(uri.to_s, response) if Cache.enabled?
    end
    StringIO.new(response)
  end
  
  class Cache
    # Cache is not enabled by default
    @cache_enabled = false
    
    class << self
      attr_writer :expiry, :host
      
      # Is the cache enabled?
      def enabled?
        @cache_enabled
      end
      
      # Enable caching
      def enable!
        @cache ||= Memcached.new(host, {:namespace => 'openuri'})
        @cache_enabled = true
      end
      
      # Disable caching - all queries will be run directly 
      # using the standard OpenURI `open` method.
      def disable!
        @cache_enabled = false
      end

      def disabled?
        !@cache_enabled
      end
      
      def get(key)
        @cache.get(key)
      end
      
      def set(key, value)
        @cache.set(key, value, expiry)
      end
            
      # How long your caches will be kept for (in seconds)
      def expiry
        @expiry ||= 60 * 10
      end
      
      def host
        @host ||= "127.0.0.1:11211"
      end
    end
  end
end