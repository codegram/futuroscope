require 'spec_helper'
require 'futuroscope/worker'
require 'futuroscope/pool'

module Futuroscope
  describe Worker do
    it "asks the pool for a new job and runs the future" do
      future = double(:future)
      pool = [future]
      expect(future).to receive :run_future

      Worker.new(pool).run
      sleep(1)
    end
  end
end
