module Futuroscope
  # A futuroscope worker takes care of resolving a future's value. It works
  # together with a Pool.
  class Worker
    # Public: Initializes a new Worker.
    #
    # pool - The worker Pool it belongs to.
    def initialize(pool)
      @pool = pool
    end

    # Runs the worker. It keeps asking the Pool for a new job. If the pool
    # decides there's no job use it now or in the future, it will die and the
    # Pool will be notified. Otherwise, it will be given a new job or blocked
    # until there's a new future available to process.
    #
    def run
      @thread = Thread.new do
        while(future = @pool.pop) do
          future.run_future
        end
        die
      end
    end

    # Public: Stops this worker.
    def stop
      @thread.kill
      die
    end

    private

    def die
      @pool.worker_died(self)
    end
  end
end
