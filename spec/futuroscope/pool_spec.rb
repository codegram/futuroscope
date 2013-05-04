require 'spec_helper'
require 'futuroscope/pool'

module Futuroscope
  describe Pool do
    it "spins up a number of threads" do
      pool = Pool.new(2)
      expect(pool.threads).to have(2).threads

      pool = Pool.new(3)
      expect(pool.threads).to have(3).threads
    end

    describe "queue" do
      it "enqueues a job and runs it" do
        pool = Pool.new
        future = double(:future)

        future.should_receive :run_future
        pool.queue future
        sleep(0.1)
      end
    end
  end
end
