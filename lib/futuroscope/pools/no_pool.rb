module Futuroscope
  module Pools
    # A pool, that does not actually do any thread pooling, but just runs
    # futures right away.
    class NoPool < Pool
      def queue(future)
        future.run_future
      end
    end
  end
end
