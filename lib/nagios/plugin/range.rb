module Nagios

  module Plugin

    class Range
      attr_reader :start_value, :end_value, :start_infinity, :end_infinity, :alert_on

      def initialize(range)
        raise TypeError, "String is expected" unless range.is_a?(String)
        @start_value = 0
        @end_value = 0
        @start_infinity = false
        @end_infinity = false
        @alert_on = :inside
        parse_range_string(range)
      end

      def check_range(value)
        result =
          if !start_infinity && end_infinity
            start_value <= value
          elsif start_infinity && !end_infinity
            value <= end_value
          else
            start_value <= value && value <= end_value
          end
        alert_on == :outside ? result : !result
      end

      private
      def parse_range_string(range)
        @start_infinity = true if range.gsub!(/^~/, '')
        @alert_on = :outside if range.gsub!(/^@/, '')
        regexp = '([+\-]?[\d+\.]+)'
        case range
        when /^:?(#{regexp})$/ # :10 or 10
          @end_value = Float($1)
        when /^#{regexp}:#{regexp}$/ # 10:20
          @start_value = Float($1)
          @end_value = Float($2)
        when /^#{regexp}:$/ # 10:
          @start_value = Float($1)
          @end_infinity = true
        else
          raise TypeError, "Unknown threshold format. Please check the documentation http://nagiosplug.sourceforge.net/developer-guidelines.html#THRESHOLDFORMAT"
        end
      end

    end
  end

end
