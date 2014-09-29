describe Futuroscope do
  describe "default_pool" do
    it "returns a pool by default" do
      expect(Futuroscope.default_pool).to be_kind_of(Futuroscope::Pool)
    end
  end

  describe "default_pool=" do
    it "allows you to set a new default pool" do
      pool = Futuroscope::Pool.new
      Futuroscope.default_pool = pool
      expect(Futuroscope.default_pool).to equal(pool)
    end
  end

  describe "logging" do
    it "logs messages to all the given loggers" do
      logger1 = double "Logger 1"
      logger2 = double "Logger 2"
      Futuroscope.loggers << logger1 << logger2

      expect(logger1).to receive(:info).at_least(33).times
      expect(logger2).to receive(:info).at_least(33).times

      expect(logger1).to receive(:debug).at_least(7).times
      expect(logger2).to receive(:debug).at_least(7).times

      Futuroscope::Future.new { Futuroscope::Future.new { 1 } + 1 }
      sleep(0.5)
    end
  end
end
