require 'set'
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
        Futuroscope.info "PUSH:   added future #{future.__id__}"
        spin_worker if need_extra_worker?
        @priorities[future.__id__] = 0
        Futuroscope.info "        sending signal to wake up a thread"
        Futuroscope.debug "        current priorities: #{@priorities.map { |k, v| ["future #{(k)}", v] }.to_h}"
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
    # future - The Future being waited for.
    def depend(future)
      @mutex.synchronize do
        Futuroscope.info "DEPEND: thread #{Thread.current.__id__} depends on future #{future.__id__}"
        @dependencies[Thread.current] = future
        Futuroscope.debug "        current dependencies: #{@dependencies.map { |k, v| ["thread #{k.__id__}", "future #{v.__id__}"] }.to_h}"
        handle_deadlocks
        dependent_future_id = current_thread_future_id
        incr = 1 + (dependent_future_id.nil? ? 0 : @priorities[dependent_future_id])
        increment_priority(future, incr)
      end
    end


    # Semipublic: Called by a worker to indicate that it finished resolving a future.
    def done_with(future)
      @mutex.synchronize do
        Futuroscope.info "DONE:   thread #{Thread.current.__id__} is done with future #{future.__id__}"
        @priorities.delete_if { |future_id, priority| Futuroscope.info "        deleting future #{future_id}" if future_id == future.__id__; future_id == future.__id__ }
        @dependencies.delete_if { |dependent, dependee| Futuroscope.info "        deleting dependency from thread #{dependent.__id__} to future #{dependee.__id__}" if dependee.__id__ == future.__id__; dependee.__id__ == future.__id__ }
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
      Futuroscope.info "        spun up worker with thread #{worker.thread.__id__}"
    end


    def increment_priority(future, increment)
      return nil if NilClass === future
      Futuroscope.info "        incrementing priority for future #{future.__id__}"
      @priorities[future.__id__] += increment
      increment_priority(@dependencies[future.worker_thread], increment)
    end


    def current_thread_future_id
      @priorities.keys.find { |id| ObjectSpace._id2ref(id).worker_thread == Thread.current }
    end


    def await_future(timeout)
      until @priorities.any? { |future_id, priority| ObjectSpace._id2ref(future_id).worker_thread.nil? }
        Futuroscope.info "POP:    thread #{Thread.current.__id__} going to sleep until there's something to do#{timeout && " or #{timeout} seconds"}..."
        @future_needs_worker.wait(@mutex, timeout)
        Futuroscope.info "POP:    ... thread #{Thread.current.__id__} woke up"
        Futuroscope.debug "        current priorities: #{@priorities.map { |k, v| ["future #{(k)}", v] }.to_h}"
        Futuroscope.debug "        current future workers: #{@priorities.map { |k, v| ["future #{(k)}", (thread = ObjectSpace._id2ref(k).worker_thread; thread.nil? ? nil : "thread #{thread.__id__}")] }.to_h}"
        unless timeout.nil? || @priorities.any? { |future_id, priority| ObjectSpace._id2ref(future_id).worker_thread.nil? }
          Futuroscope.info "        thread #{Thread.current.__id__} is dying because there's nothing to do"
          workers.delete_if { |worker| worker.thread == Thread.current }
          return nil
        end
      end
      future_id = @priorities.select { |future_id, priority| ObjectSpace._id2ref(future_id).worker_thread.nil? }
      .max_by { |future_id, priority| priority }.first
      Futuroscope.info "POP:    thread #{Thread.current.__id__} will start working on future #{future_id}"
      future = ObjectSpace._id2ref(future_id)
      future.worker_thread = Thread.current
      future
    end


    def handle_deadlocks
      Thread.handle_interrupt(DeadlockError => :immediate) do
        Thread.handle_interrupt(DeadlockError => :never) do
          unless (cycle = find_cycle).nil?
            Futuroscope.error "        deadlock! cyclical dependency, sending interrupt to all threads involved"
            cycle.each { |thread| thread.raise DeadlockError, "Cyclical dependency detected, the future was aborted." }
          end
          if cycleless_deadlock?
            thread_to_interrupt = least_priority_independent_thread
            Futuroscope.error "        deadlock! ran out of workers, sending interrupt to thread #{thread_to_interrupt.__id__}"
            thread_to_interrupt.raise DeadlockError, "Pool size is too low, the future was aborted."
          end
        end
      end
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


    def cycleless_deadlock?
      workers.all? { |worker| @dependencies.has_key?(worker.thread) } && workers.count == max_workers
    end


    def least_priority_independent_thread
      @priorities.sort_by(&:last).map(&:first).each do |future_id|
        its_thread = ObjectSpace._id2ref(future_id).worker_thread
        return its_thread if !its_thread.nil? && @dependencies[its_thread].worker_thread.nil?
      end
    end

  end
end
