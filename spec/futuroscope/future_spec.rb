require 'spec_helper'
require 'futuroscope/future'
require 'timeout'

module Futuroscope
  describe Future do
    it "will return an instant value" do
      future = Future.new{ :edballs }
      sleep(0.1)

      expect(future).to eq(:edballs)
    end

    it "will execute the future in the background and wait for it" do
      future = Future.new{ sleep(1); :edballs }

      sleep(1)
      Timeout::timeout(0.9) do
        expect(future).to eq(:edballs)
      end
    end

    it "delegates some Object methods to the original object's" do
      object = [1, 2, 3]
      future = Future.new{object}

      expect(future.class).to eq(Array)
      expect(future).to be_kind_of(Enumerable)
      expect(future).to be_a(Enumerable)
      expect(future.to_s).to eq(object.to_s)
      expect(Future.new { nil }).to be_nil
    end

    it "delegates missing methods" do
      object = [1, 2, 3]
      future = Future.new{object}
      expect(future).to_not be_empty
    end

    it "captures exceptions and re-raises them when calling the value" do
      future = Future.new { raise "Ed Balls" }

      expect { future.inspect }.to raise_error RuntimeError, "Ed Balls"
    end

    it "returns the original object when future_value gets called" do
      object = double
      future = Future.new{ object }

      expect(future.future_value.object_id === object.object_id).to eq(true)
    end

    it "marshals a future object by serializing the result value" do
      object = [1, 2, 3]
      future = Future.new{object}
      dumped = Marshal.dump(future)
      expect(Marshal.load(dumped).future_value).to eq(object)
    end

    it "re-raises captured exception when trying to marshal" do
      future = Future.new { raise "Ed Balls" }

      expect { Marshal.dump(future) }.to raise_error RuntimeError, "Ed Balls"
    end

    it "correctly duplicates a future object" do
      object = [1, 2, 3]
      future = Future.new { object }

      expect(future.dup).to eq future
    end

    it "clones correctly before being resolved" do
      object = [1, 2, 3]
      future = Future.new { sleep 1; object }
      clone = future.clone

      expect(clone).to eq object
    end

    context "when at least another thread is alive" do
      # If no threads are alive, the VM raises an exception, therefore we need to ensure there is one.

      before :each do
        @live_thread = Thread.new { loop { } }
      end


      it "doesn't hang when 2 threads try to obtain its result before it's finished" do
        test_thread = Thread.new do
          future = Future.new { sleep 1; 1 }
          f1 = Future.new { future + 1 }
          f2 = Future.new { future + 2 }
          f1.future_value
          f2.future_value
        end
        sleep 2.5
        expect(test_thread).to_not be_alive
        test_thread.kill
      end


      after :each do
        @live_thread.kill
      end

    end
  end
end
