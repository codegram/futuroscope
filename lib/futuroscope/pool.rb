require 'thread'

module Futuroscope
  # Futuroscope's pool is design to control concurency and keep it between some
  # certain benefits. Moreover, we warm up the threads beforehand so we don't
  # have to spin them up each time a future is created.
  class Pool
    attr_reader :threads

    # Initializes a new Pool.
    #
    # thread_count - The number of threads that this pool is gonna have
    def initialize(thread_count = 8)
      @thread_count = thread_count
      @mutex = Mutex.new
      @queue = Queue.new
      @threads = Array.new
      spin_threads
    end

    # Enqueues a new Future into the pool.
    #
    # future - The Future to enqueue.
    def queue(future)
      @queue.push future
    end

    private

    def spin_threads
      @thread_count.times do |i|
        @threads << Thread.new do
          loop do
            @queue.pop.run_future
          end
        end
      end
    end

    def finalize
      @threads.each(&:kill)
    end
  end
end
