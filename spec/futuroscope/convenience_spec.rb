require 'spec_helper'
require 'futuroscope/convenience'
require 'timeout'

describe "Kernel#future" do
  it "adds a convenience method to ruby's kernel" do
    x = future{ sleep(1); 1 }
    y = future{ sleep(1); 2 }
    z = future{ sleep(1); 3 }

    Timeout::timeout(1.5) do
      expect(x + y + z).to eq(6)
    end
  end
end
