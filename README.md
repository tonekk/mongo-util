mongo-util
==========

[![Dependency Status](https://gemnasium.com/tonekk/mongo-util.svg)](https://gemnasium.com/tonekk/rails-js)
[![Gem Version](http://img.shields.io/gem/v/mongo-util.svg)](https://rubygems.org/gems/rails-js)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://tonekk.mit-license.org)

Copying over complete databases is not that hard with **mongodb**.
Use `mongodump` followed by `mongorestore` and there you go.
But say you want to copy *only certain records from certain collections*, things get a little bit hairy.

Why? Can't I just use some javascript and the `mongo`-shell?
No. Some mongo commands just don't have authentication, so I found it was the easiest way to use `mongorestore` and `mongodump` and wrap them into a handy library.


## Synopsis

```ruby

require 'mongo/util'

# Create mongo util instance, set database to fetch from and database to copy to
# as well as dump folder
mongo = Mongo::Util.new({ host: 'foo.mongohosting.com', port: 31337, db: 'foo' },
                        { db: 'foo_development' },
                        'mongo_dump')

# Add authentication
mongo.from = { user: 'root', password: 'password' }

# Iterate over collections
mongo.collections.each do |collection|

  # Add some case here
  if collection == 'some.collection'

    # Add queries here as you like
    mongo.dump(collection: collection, query: { something: false }) &&
    mongo.remove(collection, query: { something: false }) &&
    mongo.restore
    
  else
  
    # Just copy
    mongo.dump(collection: collection) &&
    mongo.remove(collection) &&
    mongo.restore
    
  end

  # Clean up dump folder
  mongo.clean                                                                                                   
end

```

The snippet above is replacing the contents of all collections from `localhost:27017/foo_development` with the ones from `foo.mongohosting.com:31337/foo` (you can also specify an external db to copy to, *localhost:27017* is standard), except for `some.collection`, for which it only replaces the entries where the query `{ something: false }` matches.


## Installing

Install as you would install any other gem.
[bundler](http://bundler.io/) is your friend!

When you're using Rails and you want to use this gem for a script to get fresh production data, just use `bundle exec yourscript.rb`, where *yourscript.rb* contains something like above.


## Contributing

[Fork](https://github.com/tonekk/mongo-util/fork) -> Commit -> Pull Request
Pull
