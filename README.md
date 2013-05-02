# Futuroscope
[![Gem Version](https://badge.fury.io/rb/futuroscope.png)](http://badge.fury.io/rb/futuroscope)
[![Build Status](https://travis-ci.org/codegram/futuroscope.png?branch=master)](https://travis-ci.org/codegram/futuroscope)
[![Dependency Status](https://gemnasium.com/codegram/futuroscope.png)](https://gemnasium.com/codegram/futuroscope)
[![Coverage Status](https://coveralls.io/repos/codegram/futuroscope/badge.png?branch=master)](https://coveralls.io/r/codegram/futuroscope)

Futursocope is a simple library that implements futures in ruby. Futures are a
concurrency pattern meant to help you deal with concurrency in a simple way.

It's specially useful when working in Service Oriented Architectures where HTTP
calls can take a long time and you only expect a value from them.

[![The awesome Futuroscope park](http://europe.eurostar.com/wp-content/uploads/2011/06/Futuroscope10-59-of-107.jpg)](http://futuroscope.com)

You can learn more about futures here in this excellent article from @jpignata:
[Concurrency Patterns in Ruby:
Futures](http://tx.pignata.com/2012/11/concurrency-patterns-in-ruby-futures.html)

In Futuroscope, futures are instanciated with a simple ruby block. The future's 
execution will immediately start in a different thread and when you call a
method on in it will be forwarded to the block's return value.

If the thread didn't finish yet, it will block the program's execution until
it's finished. Otherwise, it will immediataly return its value.

Futuroscope is tested on `MRI 1.9.3`, `MRI 2.0.0`, `JRuby` and `Rubinius`.

## Installation

Add this line to your application's Gemfile:

    gem 'futuroscope'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install futuroscope

## Usage

```Ruby
require 'futuroscope'

x = Futuroscope::Future.new{ sleep(1); 1 }
y = Futuroscope::Future.new{ sleep(1); 2 }
z = Futuroscope::Future.new{ sleep(1); 3 }

# This execution will actually take just one second and not three like you
# would expect.

puts x + y + z
=> 6
```

If you don't mind polluting the `Kernel` module, you can also require
futuroscope's convenience `future` method:

```Ruby
require 'futuroscope/convenience'

x = future{ sleep(1); 1 }
y = future{ sleep(1); 2 }
z = future{ sleep(1); 3 }

puts x + y + z
=> 6
```

## Ideas for the future

* Having a thread pool so you can limit maximum concurrency.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
