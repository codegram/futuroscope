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
      @dependencies = {}
      @priorities = {}
      @future_needs_worker = ConditionVariable.new
      @workers = ::Set.new
      @mutex = ::Mutex.new
      warm_up_workers
    end

    # Public: Pushes a Future into the worklist with low priority.
    #
    # future - The Future to push.
    def push(future)
      @mutex.synchronize do
        spin_worker if need_extra_worker?
        @priorities[future.__id__] = 0
        @future_needs_worker.signal
      end
    end

    # Public: Pops a new job from the pool. It will return nil if there's
    # enough workers in the pool to take care of it.
    #
    # Returns a Future
    def pop
      @mutex.synchronize do
        kill_worker = more_workers_than_needed? && @priorities.empty?
        await_future(kill_worker ? 5 : nil)
      end
    end

    # Public: Indicates that the current thread is waiting for a Future.
    #
    # dependee - The Future being waited for.
    def depend(future)
      @mutex.synchronize do
        @dependencies[Thread.current] = future
        handle_deadlocks
        dependent_future_id = current_thread_future_id
        incr = 1 + (dependent_future_id.nil? ? 0 : @priorities[dependent_future_id])
        increment_priority(future, incr)
      end
    end

    # Semipublic: Called by a worker to indicate that it finished resolving a future.
    def done_with(future)
      @mutex.synchronize do
        @priorities.delete_if { |future_id, priority| future_id == future.__id__ }
        @dependencies.delete_if { |dependent, dependee| dependee.__id__ == future.__id__ }
      end
    end

    def min_workers=(count)
      @min_workers = count
      warm_up_workers
    end

    private

    def warm_up_workers
      @mutex.synchronize do
        while workers.length < @min_workers do
          spin_worker
        end
      end
    end

    def need_extra_worker?
      workers.length < max_workers && @priorities.length > workers.count(&:free)
    end

    def more_workers_than_needed?
      workers.length > min_workers && @priorities.length < workers.count(&:free)
    end

    def finalize
      workers.each { |worker| worker.thread.kill }
    end

    # The below methods should only be called with @mutex already acquired.
    # These are only extracted for readability purposes.


    def spin_worker
      worker = Worker.new(self)
      workers << worker
      worker.run
    end

    def find_cycle
      chain = [Thread.current]
      loop do
        last_thread = chain.last
        return nil unless @dependencies.has_key?(last_thread)
        next_future = @dependencies[last_thread]
        next_thread = next_future.worker_thread
        return nil if next_thread.nil?
        return chain if next_thread == chain.first
        chain << next_thread
      end
    end

    def increment_priority(future, increment)
      return nil if NilClass === future
      @priorities[future.__id__] += increment
      increment_priority(@dependencies[future.worker_thread], increment)
    end

    def current_thread_future_id
      @priorities.keys.find { |id| ObjectSpace._id2ref(id).worker_thread == Thread.current }
    end

    def await_future(timeout)
      until @priorities.any? { |future_id, priority| ObjectSpace._id2ref(future_id).worker_thread.nil? }
        @future_needs_worker.wait(@mutex, timeout)
        unless timeout.nil? || @priorities.any? { |future_id, priority| ObjectSpace._id2ref(future_id).worker_thread.nil? }
          workers.delete_if { |worker| worker.thread == Thread.current }
          return nil
        end
      end
      future_id = @priorities.select { |future_id, priority| ObjectSpace._id2ref(future_id).worker_thread.nil? }
      .max_by { |future_id, priority| priority }.first
      future = ObjectSpace._id2ref(future_id)
      future.worker_thread = Thread.current
      future
    end

    def handle_deadlocks
      Thread.handle_interrupt(DeadlockError => :immediate) do
        Thread.handle_interrupt(DeadlockError => :never) do
          unless (cycle = find_cycle).nil?
            cycle.each { |thread| thread.raise DeadlockError, "Cyclical dependency detected, the future was aborted." }
          end
          if workers.all? { |worker| @dependencies.has_key?(worker.thread) } && workers.count == max_workers
            least_priority_future = ObjectSpace._id2ref(@priorities.min_by { |future_id, priority| priority }.first)
            least_priority_future.worker_thread.raise DeadlockError, "Pool size is too low, the future was aborted."
          end
        end
      end
    end

  end
end
