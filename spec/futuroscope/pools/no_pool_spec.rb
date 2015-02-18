module Futuroscope
  module Pools
    describe NoPool do
      it "should run queued futures on the same thread" do
        pool = NoPool.new
        future = Future.new(pool) { Thread.current }

        expect(future).to eq Thread.current
      end
    end
  end
end
