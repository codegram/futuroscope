require 'spec_helper'
require 'futuroscope/pool'

module Futuroscope
  describe Pool do
    it "spins up a number of workers" do
      pool = Pool.new(2)
      expect(pool.workers).to have(2).workers

      pool = Pool.new(3)
      expect(pool.workers).to have(3).workers
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

    describe "worker control" do
      it "adds more workers when needed and returns to the default amount" do
        pool = Pool.new(2, 8)
        10.times do |future|
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(8).workers

        sleep(1.5)
        expect(pool.workers).to have(2).workers
      end

      it "allows overriding min workers real time" do
        pool = Pool.new(2, 8)
        pool.min_workers = 3
        expect(pool.workers).to have(3).workers
      end

      it "allows overriding max workers real time" do
        pool = Pool.new(2, 8)
        pool.max_workers = 4

        10.times do |future|
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(4).workers
      end
    end
  end
end
