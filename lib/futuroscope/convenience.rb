require 'futuroscope'

module Kernel
  def future(pool = Futuroscope.default_pool, &block)
    Futuroscope::Future.new(pool, &block)
  end
end

module Enumerable
  def future_map(&block)
    Futuroscope::Map.new(self).map(&block)
  end
end
