require "futuroscope/deadlock_error"
require "futuroscope/future"
require "futuroscope/map"
require "futuroscope/pool"
require "futuroscope/version"

module Futuroscope
  # Gets the default futuroscope's pool.
  #
  # Returns a Pool
  def self.default_pool
    @default_pool ||= Pool.new
  end

  # Sets a new default pool. It's useful when you want to set a different
  # number of concurrent threads.
  #
  # Example:
  #   Futuroscope.default_pool = Futuroscope::Pool.new(24)
  #
  def self.default_pool=(pool)
    @default_pool = pool
  end

  # Gets the current loggers. Add objects to it that have the below methods defined to log on them.
  # For example, instances of Ruby's core Logger will work.
  def self.loggers
    @loggers ||= []
  end

  # Inward facing methods, called whenever a component wants to log something to the loggers.
  [:debug, :info, :warn, :error, :fatal].each do |log_method|
    define_singleton_method(log_method) do |message|
      loggers.each { |logger| logger.send(log_method, message) }
    end
  end
end
