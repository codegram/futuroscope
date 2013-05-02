module Futuroscope
  class Future
    attr_writer :__value

    # Initializes a future with a block and starts its execution.
    #
    # Examples:
    #
    #   future = Futuroscope::Future.new { sleep(1); :edballs }
    #   sleep(1)
    #   future.value 
    #   => :edballs
    #   # This will return in 1 second and not 2 if the execution wasn't
    #   # deferred to a thread.
    #
    # block - A block that will be run in the background.
    #
    # Returns a Future
    def initialize(&block)
      @mutex = Mutex.new

      @thread = Thread.new do
        result = block.call
        self.__value = result
      end
    end

    # Semipublic: Returns the future's value. Will wait for the future to be 
    # completed or return its value otherwise. Can be called multiple times.
    #
    # Returns the Future's block execution result.
    def __value
      @mutex.synchronize do
        return @__value if defined?(@__value)
      end
      @thread.join
      @__value
    end

    private

    def method_missing(method, *args)
      __value.send(method, *args)
    end

    def respond_to_missing?(method, include_private = false)
      __value.respond_to?(method, include_private)
    end

    def __value=(value)
      @mutex.synchronize do
        @__value = value
      end
    end
  end
end
