require 'futuroscope/future'

module Kernel
  def future(&block)
    Futuroscope::Future.new(&block)
  end
end
