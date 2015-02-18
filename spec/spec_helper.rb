if ENV["CI"] && RUBY_ENGINE == "ruby"
  require "coveralls"
  Coveralls.wear!
end

require "rspec/collection_matchers"
require "futuroscope"
