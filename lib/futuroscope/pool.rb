require 'set'
require 'thread'
require 'futuroscope/worker'

module Futuroscope
  # Futuroscope's pool is design to control concurency and keep it between some
  # certain benefits. Moreover, we warm up the threads beforehand so we don't
  # have to spin them up each time a future is created.
  class Pool
    attr_reader :workers
    attr_accessor :min_workers, :max_workers

    # Public: Initializes a new Pool.
    #
    # thread_count - The number of workers that this pool is gonna have
    def initialize(range = 8..16)
      @min_workers = range.min
      @max_workers = range.max
      @queue = Queue.new
      @workers = Set.new
      @mutex = Mutex.new
      warm_up_workers
    end

    # Public: Enqueues a new Future into the pool.
    #
    # future - The Future to enqueue.
    def queue(future)
      @mutex.synchronize do
        spin_worker if can_spin_extra_workers?
        @queue.push future
      end
    end

    # Public: Pops a new job from the pool. It will return nil if there's 
    # enough workers in the pool to take care of it.
    #
    # Returns a Future
    def pop
      @mutex.synchronize do
        return nil if @queue.empty? && more_workers_than_needed?
      end
      return @queue.pop
    end

    # Private: Notifies that a worker just died so it can be removed from the
    # pool.
    #
    # worker - A Worker
    def worker_died(worker)
      @mutex.synchronize do
        @workers.delete(worker)
      end
    end

    def min_workers=(count)
      @min_workers = count
      warm_up_workers
    end

    private

    def warm_up_workers
      @mutex.synchronize do
        while(@workers.length < @min_workers) do
          spin_worker
        end
      end
    end

    def can_spin_extra_workers?
      @workers.length < @max_workers && span_chance
    end

    def span_chance
      [true, false].sample
    end

    def more_workers_than_needed?
      @workers.length > @min_workers
    end

    def spin_worker
      worker = Worker.new(self)
      @workers << worker
      worker.run
    end

    def finalize
      @workers.each(&:stop)
    end
  end
end
