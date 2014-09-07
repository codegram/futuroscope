module Futuroscope
  # A pool runs futures in an implementation-specific way.
  #
  # The default implementation is the WorkerPool, that runs futures concurrently
  # in threads.
  class Pool
    # Public: Enqueues a new Future into the pool.
    #
    # future - The Future to enqueue.
    def queue(future)
    end
  end
end
