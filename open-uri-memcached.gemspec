Gem::Specification.new do |s|
  s.name = "openuri_memcached"
  s.version = '0.1.2'
  s.email = "ben@germanforblack.com"
  s.homepage = "http://github.com/benschwarz/open-uri-memcached"
  s.description = "OpenURI with transparent caching"
  s.authors = ["Ben Schwarz"]
  s.summary = "The same OpenURI that you know and love with the power of Memcached"
  s.files = %w(README lib/openuri_memcached.rb)
  
  # Deps
  s.add_dependency("memcached", ">= 0.10")
end