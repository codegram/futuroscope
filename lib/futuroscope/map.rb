require 'futuroscope/future'

module Futuroscope
  # A futuroscope map behaves like a regular map but performs all operations
  # using futures so they're effectively parallel.
  #
  class Map
    # Initializes a map with a set of items.
    #
    # items - Items in which to perform the mapping
    #
    def initialize(items)
      @items = items
    end

    # Maps each item with a future.
    #
    # block - A block that will be executed passing each element as a parameter
    #
    # Returns an array of futures that behave like the original objects.
    def map(&block)
      @items.map do |item|
        Future.new do
          block.call(item)
        end
      end
    end
  end
end
