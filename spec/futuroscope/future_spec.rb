require 'spec_helper'
require 'futuroscope/future'
require 'timeout'

module Futuroscope
  describe Future do
    it "will return an instant value" do
      future = Future.new{ :edballs }
      sleep(0.1)

      expect(future.to_sym).to eq(:edballs)
    end

    it "will execute the future in the background and wait for it" do
      future = Future.new{ sleep(1); :edballs }

      sleep(1)
      Timeout::timeout(0.9) do
        expect(future.to_sym).to eq(:edballs)
      end
    end
  end
end
