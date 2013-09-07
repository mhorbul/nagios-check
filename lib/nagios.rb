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

  module Plugin
    autoload :Range,     "nagios/plugin/range"
    autoload :Threshold, "nagios/plugin/threshold"
    autoload :Base,      "nagios/plugin/base"
  end

end
