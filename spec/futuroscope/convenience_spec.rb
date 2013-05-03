require 'spec_helper'
require 'futuroscope/convenience'
require 'timeout'

describe "Kernel#future" do
  it "adds a convenience method to ruby's kernel" do
    x = future{ sleep(1); 1 }
    y = future{ sleep(1); 2 }
    z = future{ sleep(1); 3 }

    Timeout::timeout(2.5) do
      expect(x + y + z).to eq(6)
    end
  end
end

describe "Enumerable#future_map" do
  it "adds a future_map method do Enumerable" do
    items = [1, 2, 3]
    map = items.future_map do |i|
      sleep(1)
      i + 1
    end

    Timeout::timeout(2.5) do
      expect(map.first).to eq(2)
      expect(map[1]).to eq(3)
      expect(map.last).to eq(4)
    end
  end
end
