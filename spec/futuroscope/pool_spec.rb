require 'spec_helper'
require 'futuroscope/pool'

module Futuroscope
  describe Pool do
    it "spins up a number of workers" do
      pool = Pool.new(2..4)
      expect(pool.workers).to have(2).workers

      pool = Pool.new(3..4)
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
        pool = Pool.new(2..8)
        pool.stub(:span_chance).and_return true
        10.times do |future|
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(8).workers

        sleep(1.5)
        expect(pool.workers).to have(2).workers
      end

      it "allows overriding min workers real time" do
        pool = Pool.new(2..8)
        pool.min_workers = 3
        expect(pool.workers).to have(3).workers
      end

      it "allows overriding max workers real time" do
        pool = Pool.new(2..8)
        pool.stub(:span_chance).and_return true
        pool.max_workers = 4

        10.times do |future|
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(4).workers
      end
    end

    describe "#finalize" do
      it "shuts down all its workers" do
        pool = Pool.new(2..8)

        pool.send(:finalize)

        expect(pool.workers).to have(0).workers
      end
    end

    describe "#span_chance" do
      it "returns true or false randomly" do
        pool = Pool.new
        chance = pool.send(:span_chance)

        expect([true, false]).to include(chance)
      end
    end
  end
end
