require 'spec_helper'
require 'futuroscope'

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
end
