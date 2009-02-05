$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec'

specs = lambda do
  describe OpenURI::Cache, "init" do
    it "should be disabled" do
      OpenURI::Cache.should be_disabled
    end
  end

  describe OpenURI, "module" do
    before :all do
      @url = 'http://google.com'
    end

    before do
      OpenURI::Cache.disable!
    end

    it "should query a resource without cache" do
      open(@url).read.should =~ /html/
    end

    it "should read a resource from the cache" do
      data = open(@url).read
      OpenURI::Cache.enable!
      begin
        OpenURI::Cache.set @url, 'snarf'
        open(@url).read.should == 'snarf'
      ensure
        OpenURI::Cache.set @url, data
      end
    end

    it "should query a resource with cache" do
      OpenURI::Cache.enable!
      OpenURI::Cache.should be_enabled
      open(@url).read.should =~ /html/
    end

    it "should query a resource with cache when using block syntax" do
      OpenURI::Cache.enable!
      OpenURI::Cache.should be_enabled
      open(@url) { |f| f.read }.should =~ /html/
    end
    
    it "should not interfere with standard operation of Kernel::open" do
      lambda { open("./spec/assets/test") }.should_not raise_error
    end

    it "should not interfere with standard operation of Kernel::open when passed a block" do
      lambda { open("./spec/assets/test") { |f| f.read } }.should_not raise_error
    end

    it "should still be able to open and read a file" do
      open("./spec/assets/test").read.should == "I have been read!"
    end

    it "should still be to open and read a file when passed a block" do
      open("./spec/assets/test") { |f| f.read }.should == "I have been read!"
    end
  end

  describe OpenURI::Cache, "class" do  
    it "should be able to be enabled" do
      OpenURI::Cache.enable!
      OpenURI::Cache.should be_enabled
    end
  
    it "should be able to be disabled" do
      OpenURI::Cache.enable!
      OpenURI::Cache.disable!
      OpenURI::Cache.should be_disabled
    end
  
    it "should cache for a default of 10 minutes" do
      OpenURI::Cache.expiry.should eql(60 * 10)
    end
  
    it "should allow a userset cache expiry timeframe" do
      default_expiry = OpenURI::Cache.expiry
      begin
        OpenURI::Cache.expiry = 60 * 15
        OpenURI::Cache.expiry.should eql(60 * 15)
      ensure
        OpenURI::Cache.expiry = default_expiry
      end
    end
  
    it "should allow a userset host" do
      default_server = "127.0.0.1:11211"
      server = "10.1.1.1:11211"
      OpenURI::Cache.host.should eql(default_server)
      begin
        OpenURI::Cache.host = server
        OpenURI::Cache.host.should eql(server)
      ensure
        OpenURI::Cache.host = default_server
      end
    end
  end
end

require 'logger'
require 'stringio'

module Rails
  class << self
    attr_accessor :cache
  end
end

# TODO: write to a log file?
logger = Logger.new(StringIO.new)

{
  'memcached' => lambda { require 'openuri/memcached' },
  'rails-cache with memory cache' => lambda {
    gem 'activesupport', '>= 2.1'
    require 'active_support'
    require 'openuri/rails-cache'
    ActiveSupport::Cache::Store.logger = logger
    before :all do
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
    end
  },
  'rails-cache with memcache cache' => lambda {
    gem 'activesupport', '>= 2.1'
    require 'active_support'
    require 'openuri/rails-cache'
    ActiveSupport::Cache::Store.logger = logger
    before :all do
      Rails.cache = ActiveSupport::Cache::MemCacheStore.new('127.0.0.1:11211')
    end
  }
}.each do |key, before|
  begin
    describe key do
      instance_eval &before
      instance_eval &specs
    end
  rescue Gem::LoadError
    puts $!.to_s
  end
end