module Nagios
  module Plugin
    class Base

      attr_reader :threshold, :options

      class << self
        def shortname(value = nil)
          @shortname = value if value
          @shortname
        end
      end

      def initialize
        @threshold = Threshold.new
        @options = {}.merge!(default_options)
      end

      def run(args)
        parse(args)
        begin
          check
        rescue => e
          nagios_exit(:unknown, e.to_s)
        end
      end

      def perfoutput
      end

      def default_options
        {}
      end

      def parse(args)
        option_parser(args)
      end

      def nagios_exit(code, message)
        exit_code = code.is_a?(Symbol) ? Nagios::EXIT_CODE[code] : code
        reversed_exit_codes = Nagios::EXIT_CODE.to_a.reduce([]) { |r,v| r << v.reverse }
        exit_status = Hash[reversed_exit_codes][exit_code]
        unless exit_status
          puts "UNKNOWN - exit code '#{code}' is not found."
          exit UNKNOWN
        end
        output = exit_status.to_s.upcase
        output << " - #{message}"
        output = self.class.shortname.nil? ? output : "#{self.clas.shortname.shortname} #{output}"
        output << " | #{perfoutput}" if perfoutput
        puts output
        exit exit_code
      end

      def check_threshold(value)
        self.threshold.get_status(value)
      end

      private
      def option_parser(args)
        OptionParser.new do |opt|
          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
          opt.on("-w", "--warning WARNING", "WARNING Threshold") do |value|
            threshold.warn(value)
          end
          opt.on("-c", "--critical CRITICAL", "CRITICAL Threshold") do |value|
            threshold.crit(value)
          end
          yield opt if block_given?
        end.parse!(args)
      end

      def check
        raise "#{self.class.name}#check method should be implemented in the child class"
      end

    end
  end
end
