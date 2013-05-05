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
      expect(future.clone).to eq(object)
      expect(future.to_s).to eq(object.to_s)
    end

    it "delegates missing methods" do
      object = [1, 2, 3]
      future = Future.new{object}
      expect(future).to_not be_empty
    end

    it "captures exceptions and re-raises them when calling the value" do
      future = Future.new{ raise "Ed Balls" }

      expect(lambda{
        future.inspect
      }).to raise_error(Exception)
    end
  end
end
