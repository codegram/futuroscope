require 'spec_helper'
require 'futuroscope/worker'
require 'futuroscope/pool'

module Futuroscope
  describe Worker do
    it "asks the pool for a new job and runs the future" do
      future = double(:future)
      pool = [future]
      future.should_receive :run_future

      Worker.new(pool).run
      sleep(1)
    end

    it "notifies the pool when the worker died because there's no job" do
      pool = []
      worker = Worker.new(pool)

      pool.should_receive(:worker_died).with(worker)
      worker.run
      sleep(1)
    end
  end
end
