module Futuroscope
  describe Pool do
    it "spins up a number of workers" do
      pool = Pool.new(2..4)
      expect(pool.workers).to have(2).workers

      pool = Pool.new(3..4)
      expect(pool.workers).to have(3).workers
    end

    describe "push" do
      it "enqueues a job and runs it" do
        pool = Pool.new
        future = Struct.new(:worker_thread).new(nil)

        expect(future).to receive :resolve!
        pool.push future
        sleep(0.1)
      end
    end

    describe "depend" do
      it "detects cyclical dependencies" do
        pool = Pool.new(2..2)
        f2 = nil
        f1 = Future.new(pool) { f2 = Future.new(pool) { f1.future_value }; f2.future_value }

        expect { f1.future_value }.to raise_error Futuroscope::DeadlockError, /Cyclical dependency detected/
        expect { f2.future_value }.to raise_error Futuroscope::DeadlockError, /Cyclical dependency detected/
      end

      it "detects non-cyclical deadlocks (when the pool is full and all futures are waiting for another future)" do
        pool = Pool.new(1..1)
        f = Future.new(pool) { Future.new(pool) { 1 } + 1 }

        expect { f.future_value }.to raise_error Futuroscope::DeadlockError, /Pool size is too low/
      end
    end

    describe "worker control" do
      it "adds more workers when needed and returns to the default amount" do
        pool = Pool.new(2..8)
        10.times do
          Future.new(pool){ sleep(1) }
        end

        sleep(0.5)
        expect(pool.workers).to have(8).workers

        sleep(3)
        expect(pool.workers).to have(2).workers
      end

      it "allows overriding min workers real time" do
        pool = Pool.new(2..8)
        pool.min_workers = 3
        expect(pool.workers).to have(3).workers
      end

      it "allows overriding max workers real time" do
        pool = Pool.new(2..8)
        allow(pool).to receive(:span_chance).and_return true
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
  end
end
