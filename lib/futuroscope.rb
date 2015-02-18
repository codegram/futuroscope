require "futuroscope/version"

require "futuroscope/future"

require "futuroscope/pool"
require "futuroscope/pools/worker"
require "futuroscope/pools/worker_pool"
require "futuroscope/pools/no_pool"

require "futuroscope/map"

module Futuroscope
  # Gets the default futuroscope's pool.
  #
  # Returns a Pool
  def self.default_pool
    @default_pool ||= Pools::WorkerPool.new
  end

  # Sets a new default pool. It's useful when you want to set a different
  # number of concurrent threads.
  #
  # Example:
  #   Futuroscope.default_pool = Futuroscope::Pool.new(24)
  def self.default_pool=(pool)
    @default_pool = pool
  end
end
