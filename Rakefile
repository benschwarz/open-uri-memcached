require 'lib/openuri_memcached'
require "rake/clean"
require "rake/gempackagetask"

spec = Gem::Specification.new do |s| 
  s.name = "openuri_memcached"
  s.version = OpenURI::Cache::VERSION
  s.author = "Ben Schwarz"
  s.email = "ben@germanforblack.com"
  s.homepage = "http://germanforblack.com/"
  s.platform = Gem::Platform::RUBY
  s.summary = "The same OpenURI that you know and love with the power of Memcached"
  s.description = s.summary
  s.files = %w(README Rakefile lib/openuri_memcached.rb)
  s.add_dependency("memcache-client", ">= 1.2.1")
  s.rubyforge_project = "schwarz"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

# Windows install support
windows = (PLATFORM =~ /win32|cygwin/) rescue nil
SUDO = windows ? "" : "sudo"

desc "Install openuri_memcached"
task :install => [:package] do
  sh %{#{SUDO} gem install --local pkg/openuri_memcached-#{OpenURI::Cache::VERSION}.gem}
end