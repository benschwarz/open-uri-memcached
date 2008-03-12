$:.unshift File.dirname(__FILE__)

%w(openuri_memcached version).each{|r| require File.join(File.dirname(__FILE__), 'openuri_memcached', r)}