require 'futuroscope/future'
require 'futuroscope/map'

module Kernel
  def future(&block)
    Futuroscope::Future.new(&block)
  end
end

module Enumerable
  def future_map(&block)
    Futuroscope::Map.new(self).map(&block)
  end
end
