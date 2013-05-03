require 'spec_helper'
require 'futuroscope/map'

module Futuroscope
  describe Map do
    it "behaves like a normal map" do
      items = [1, 2, 3]
      result = Map.new(items).map do |item|
        sleep(item)
        "Item #{item}"
      end
      
      Timeout::timeout(4) do
        expect(result.first).to eq("Item 1")
        expect(result[1]).to eq("Item 2")
        expect(result.last).to eq("Item 3")
      end
    end
  end
end
