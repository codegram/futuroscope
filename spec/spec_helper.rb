if ENV["CI"] && RUBY_ENGINE == "ruby"
  require 'coveralls'
  Coveralls.wear!
end

require 'futuroscope'
