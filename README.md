# Futuroscope
[![Gem Version](https://badge.fury.io/rb/futuroscope.png)](http://badge.fury.io/rb/futuroscope)
[![Build Status](https://travis-ci.org/codegram/futuroscope.png?branch=master)](https://travis-ci.org/codegram/futuroscope)
[![Code Climate](https://codeclimate.com/github/codegram/futuroscope.png)](https://codeclimate.com/github/codegram/futuroscope)
[![Coverage Status](https://coveralls.io/repos/codegram/futuroscope/badge.png?branch=master)](https://coveralls.io/r/codegram/futuroscope)
[![Dependency Status](https://gemnasium.com/codegram/futuroscope.png)](https://gemnasium.com/codegram/futuroscope)

**Join a live discussion on Gitter**: [![Gitter chat](https://badges.gitter.im/codegram/futuroscope.png)](https://gitter.im/codegram/futuroscope)

Futursocope is a simple library that implements futures in ruby. Futures are a
concurrency pattern meant to help you deal with threads in a simple, transparent way.

It's specially useful in situations where you have calls to an expensive resource that
could be done in parallel (they are not chained), but you don't wanna deal with low-level
threads. HTTP calls are a good example.

Also useful when you want to spin up a process that runs in the background, do some stuff 
in the middle, and wait for that process to return.

[![The awesome Futuroscope park](http://europe.eurostar.com/wp-content/uploads/2011/06/Futuroscope10-59-of-107.jpg)](http://futuroscope.com)

You can learn more about futures here in this excellent article from @jpignata:
[Concurrency Patterns in Ruby:
Futures](http://tx.pignata.com/2012/11/concurrency-patterns-in-ruby-futures.html)

In Futuroscope, futures are instantiated with a simple ruby block. The future's
execution will immediately start in a different thread and when you call a
method on in it will be forwarded to the block's return value.

If the thread didn't finish yet, it will block the program's execution until
it's finished. Otherwise, it will immediately return its value.

Futuroscope is tested on `MRI 1.9.3`, `MRI 2.0.0`, `MRI 2.1.0`, `Rubinius (2.2.3)` and `JRuby (1.9)`.

Check out [futuroscope's post on Codegram's blog](http://blog.codegram.com/2013/5/new-gem-released-futuroscope) to get started.

## Installation

Add this line to your application's Gemfile:

    gem 'futuroscope'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install futuroscope

## Usage

### Simple futures
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

Since a `future` is actually delegating everything to the future's value, there
might be some cases where you want to get the actual future's value. You can do
it just by calling the `future_value` method on the future:

```Ruby
string = "Ed Balls"
x = future{ string }
x.future_value === string
# => true
```

### Future map
```Ruby
require 'futuroscope'

map = Futuroscope::Map.new([1, 2, 3]).map do |i|
  sleep(1)
  i + 1
end

puts map.first
=> 2

puts map[1]
=> 3

puts map.last
=> 4

# This action will actually only take 1 second.
```

### Convenience methods

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

Same for a map:

```Ruby
require 'futuroscope/convenience'

items = [1, 2, 3].future_map do |i|
  sleep(i)
  i + 1
end
```

## Considerations

You should never add **side-effects** to a future. They have to be thought of
like they were a local variable, with the only outcome that they're returning a
value.

You have to take into account that they really run in a different thread, so
you'll be potentially accessing code in parallel that could not be thread-safe.

If you're looking for other ways to improve your code performance via
concurrency, you should probably deal directly with [Ruby's
threads](http://ruby-doc.org/core-2.0/Thread.html).

## Worker Pool

Futures are scheduled in a worker pool that helps managing concurrency in a way
that doesn't get out of hands. Also comes with great benefits since their
threads are spawned at load time (and not in runtime).

The default thread pool comes with a concurrency of 8 Workers, which seems
reasonable for the most use cases. It will elastically expand to the default of
16 threads and will kill them when they're not needed.

The default thread pool can be configured like this:

```Ruby
Futuroscope.default_pool.min_workers = 2
Futuroscope.default_pool.max_workers = 16
```

Also, each future can be scheduled to a different pool like this:

```Ruby
pool = Futuroscope::Pool.new(16..32)

future = Future.new(pool){ :edballs }

# Or with the convenience method
future = future(pool){ :edballs }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/codegram/futuroscope/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

