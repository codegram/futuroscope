module Futuroscope
  # A futuroscope worker takes care of resolving a future's value. It works
  # together with a Pool.
  class Worker
    attr_reader :thread, :free

    # Public: Initializes a new Worker.
    #
    # pool - The worker Pool it belongs to.
    def initialize(pool)
      @pool = pool
      @free = true
    end

    # Runs the worker. It keeps asking the Pool for a new job. If the pool
    # decides there's no job use it now or in the future, it will die and the
    # Pool will be notified. Otherwise, it will be given a new job or blocked
    # until there's a new future available to process.
    #
    def run
      @thread = Thread.new do
        Thread.handle_interrupt(DeadlockError => :never) do
          while future = @pool.pop do
            @free = false
            future.resolve!
            @free = true
          end
        end
      end
    end
  end
end
