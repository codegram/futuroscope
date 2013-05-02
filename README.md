# Futuroscope

Futursocope is a simple library that implements futures in ruby. Futures are a
concurrency pattern meant to help you deal with concurrency in a simple way.

You can learn more about futures here in this excellent article from @jpignata:
[Concurrency Patterns in Ruby:
Futures](http://tx.pignata.com/2012/11/concurrency-patterns-in-ruby-futures.html)

In Futuroscope, futures are instanciated with a simple ruby block. The future's 
execution will immediately start in a different thread and when you call a
method on in it will be forwarded to the block's return value.

If the thread didn't finish yet, it will block the program's execution until
it's finished. Otherwise, it will immediataly return its value.

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
