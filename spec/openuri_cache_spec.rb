require File.join(File.dirname(__FILE__), '..', 'lib', 'openuri_memcached')

describe OpenURI::Cache, "init" do
  it "should be disabled" do
    OpenURI::Cache.should be_disabled
  end
end

describe OpenURI, "module" do
  it "should query a resource without cache" do
    open('http://google.com').read.should =~ /html/
  end
  
  it "should query a resource with cache" do
    OpenURI::Cache.enable!
    OpenURI::Cache.should be_enabled
    open('http://google.com').read.should =~ /html/
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
    OpenURI::Cache.expiry = 60 * 15
    OpenURI::Cache.expiry.should eql(60 * 15)
  end
  
  it "should allow a userset host" do
    server = "10.1.1.1:11211"
    OpenURI::Cache.host.should eql("127.0.0.1:11211")
    OpenURI::Cache.host = server
    OpenURI::Cache.host.should eql(server)
  end
end
