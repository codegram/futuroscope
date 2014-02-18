require 'thread'
require 'delegate'
require 'forwardable'

module Futuroscope
  # A Future is an object that gets initialized with a block and will behave
  # exactly like the block's result, but being able to "borrow" its result from
  # the future. That is, will block when the result is not ready until it is,
  # and will return it instantly if the thread's execution already finished.
  #
  class Future < Delegator
    extend ::Forwardable

    # Initializes a future with a block and starts its execution.
    #
    # Examples:
    #
    #   future = Futuroscope::Future.new { sleep(1); :edballs }
    #   sleep(1)
    #   puts future
    #   => :edballs
    #   # This will return in 1 second and not 2 if the execution wasn't
    #   # deferred to a thread.
    #
    # pool  - A pool where all the futures will be scheduled.
    # block - A block that will be run in the background.
    #
    # Returns a Future
    def initialize(pool = ::Futuroscope.default_pool, &block)
      @queue = ::SizedQueue.new(1)
      @pool = pool
      @block = block
      @mutex = Mutex.new
      @pool.queue self
    end

    # Semipublic: Forces this future to be run.
    def run_future
      @queue.push(value: @block.call)
    rescue ::Exception => e
      @queue.push(exception: e)
    end

    # Semipublic: Returns the future's value. Will wait for the future to be 
    # completed or return its value otherwise. Can be called multiple times.
    #
    # Returns the Future's block execution result.
    def __getobj__
      resolved_future_value_or_raise[:value]
    end

    def __setobj__ obj
      @resolved_future = { value: obj }
    end

    def marshal_dump
      resolved_future_value_or_raise
    end

    def marshal_load value
      @resolved_future = value
    end

    def_delegators :__getobj__, :class, :kind_of?, :is_a?, :nil?

    alias_method :future_value, :__getobj__

    private

    def resolved_future_value_or_raise
      resolved = resolved_future_value

      Kernel.raise resolved[:exception] if resolved[:exception]
      resolved
    end

    def resolved_future_value
      @resolved_future || @mutex.synchronize do
        @resolved_future ||= @queue.pop
      end
    end
  end
end
