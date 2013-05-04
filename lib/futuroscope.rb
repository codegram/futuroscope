require "futuroscope/version"
require "futuroscope/future"
require "futuroscope/pool"

module Futuroscope
  def self.default_pool
    @default_pool ||= Pool.new(8)
  end
end
