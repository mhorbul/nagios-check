require 'logger'
require 'optparse'

module Nagios

  OK        = 0
  WARNING   = 1
  CRITICAL  = 2
  UNKNOWN   = 3

  EXIT_CODE = {
    :ok       => OK,
    :warning  => WARNING,
    :critical => CRITICAL,
    :unknown =>  UNKNOWN
  }

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger || Logger.new(STDOUT)
  end

  module Check
    autoload :Range,     "nagios-check/range"
    autoload :Threshold, "nagios-check/threshold"
    autoload :Base,      "nagios-check/base"
  end

end
