module Nagios
  module Check 
    class Threshold

      def initialize(thresholds = {})
        set(:warn, thresholds[:warn])
        set(:crit, thresholds[:crit])
      end

      def warn(value = nil)
        set(:warn, value) if value
        @warn
      end

      def crit(value = nil)
        set(:crit, value) if value
        @crit
      end

      def get_status(value)
        return Nagios::CRITICAL if self.crit && self.crit.check_range(value)
        return Nagios::WARNING  if self.warn && self.warn.check_range(value)
        return Nagios::OK
      end

      private
      def set(attr, value)
        return unless [:warn, :crit].include?(attr)
        return unless value
        begin
          range = Range.new(value)
          instance_variable_set("@#{attr}".to_sym, range)
        rescue => e
          Nagios.logger.warn("Can't setup a threshold value to: #{value.inspect}. #{e}")
        end
      end

    end
  end
end
