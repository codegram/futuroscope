require 'thread'

module Futuroscope
  class Pool
    def initialize(max)
      @max = max
      @mutex = Mutex.new
      @queue = Queue.new
      spin_threads
    end

    def queue(&block)
      @queue.push block
    end

    private

    def spin_threads
      @max.times do |i|
        Thread.new do
          loop do
            job = @queue.pop
            job.call()
          end
        end
      end
    end
  end
end
