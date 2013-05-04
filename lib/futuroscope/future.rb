module Futuroscope
  # A Future is an object that gets initialized with a block and will behave
  # exactly like the block's result, but being able to "borrow" its result from
  # the future. That is, will block when the result is not ready until it is,
  # and will return it instantly if the thread's execution already finished.
  #
  class Future
    attr_writer :future_value
    extend Forwardable

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
    def initialize(pool = Futuroscope.default_pool, &block)
      @mutex = Mutex.new
      @queue = Queue.new
      @pool = pool
      @block = block
      @pool.queue self
    end

    def run_future
      self.future_value = @block.call
      @queue.push :ok
    end

    # Semipublic: Returns the future's value. Will wait for the future to be 
    # completed or return its value otherwise. Can be called multiple times.
    #
    # Returns the Future's block execution result.
    def future_value
      @mutex.synchronize do
        return @future_value if defined?(@future_value)
      end
      @queue.pop
      @future_value
    end

    def_delegators :future_value, 
      :to_s, :==, :kind_of?, :is_a?, :clone, :class, :inspect, :tap, :to_enum,
      :display, :eql?, :hash, :methods, :nil?

    private

    def method_missing(method, *args)
      future_value.send(method, *args)
    end

    def respond_to_missing?(method, include_private = false)
      future_value.respond_to?(method, include_private)
    end

    def future_value=(value)
      @mutex.synchronize do
        @future_value = value
      end
    end
  end
end
