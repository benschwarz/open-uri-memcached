require 'open-uri'

begin
  require 'minigems'
rescue LoadError
  require 'rubygems'
end

require 'memcached'

module Kernel
  private 
  alias openuri_original_open open
  def open(name, *rest, &block)
    if name.respond_to?(:open)
      name.open(*rest, &block)
    elsif name.respond_to?(:to_str) &&
          %r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ name &&
          (uri = URI.parse(name)).respond_to?(:open)
      OpenURI::open(name, *rest, &block)
    else
      open_uri_original_open(name, *rest, &block)
    end
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
      response = openuri_original_open(uri, *rest).read
      Cache::set(uri.to_s, response) if Cache.enabled?
    end

    response = StringIO.new(response)

    if block_given?
      begin
        yield response
      ensure
        response.close
      end
    else
      response
    end
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
        @cache ||= Memcached.new(host, {
          :namespace => 'openuri', 
          :no_block => true,
          :buffer_requests => true
        })
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