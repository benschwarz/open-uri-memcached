# OpenURI with caching

Carelessly make OpenURI requests without getting hate mail.

## Running with MemCached

Require the library

    require 'openuri/memcached'
  
Start memcached server
  
    ben@Spinners ~/ Ϟ memcached -d

Set your memcached host/s (defaults to 127.0.0.1:11211)
  
    OpenURI::Cache.host = ['10.1.1.10:11211', '10.1.1.11:11211']

The default expiry is 15 minutes, this can be changed using the `expiry` method
    
    # Ten long minutes
    OpenURI::Cache.expiry = 600
    
## Running using Rails cache

You can also cache your OpenURI calls using Rails cache. 
require the library using `require openuri/rails-cache`
  
### Execution
Use exactly the same as you would OpenURI, only.. enable it.

    OpenURI::Cache.enable!
    # As slow a wet week
    open("http://ab-c.com.au").read 
  
Quit your app (leave memcached running) and re-run the same request, It will come from cache.

### Requirements

* Ruby
* MemCached 
* memcache (gem)
  * You will need to ensure that you have [corresponding version](http://blog.evanweaver.com/files/doc/fauna/memcached/files/COMPATIBILITY.html) of libmemcached to the memcached gem installed for installation to go by breezy

### Contributors

* [Ben Askins](http://github.com/benaskins)
* [Rick Olson](http://github.com/technoweenie)