module Nagios
  module Plugin
    class Base

      attr_reader :thresholds, :options

      class << self
        def shortname(value = nil)
          @shortname = value if value
          @shortname
        end
      end

      def initialize
        @thresholds = {}
        @options = {}.merge!(default_options)
      end

      def run(args = [])
        parse(args)
        begin
          check
        rescue => e
          nagios_exit(:unknown, "#{e.class}: #{e.to_s}\n#{e.backtrace.join("\n")}")
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

      def check_threshold(options)
        if options.is_a?(Hash)
          name, value = options.to_a.flatten
        else
          name = :default
          value = options
        end
        raise Exception, "threshold '#{name}' does not exit" unless self.thresholds[name]
        self.thresholds[name].get_status(value)
      end

      def add_threshold(name, values = {})
        @thresholds[name] ||= Threshold.new
        @thresholds[name].send(:warn, values[:warn]) if values[:warn]
        @thresholds[name].send(:crit, values[:crit]) if values[:crit]
      end

      private
      def option_parser(args)
        OptionParser.new do |opt|
          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
          opt.on("-w", "--warning WARNING", "WARNING Threshold") do |value|
            add_threshold(:default, :warn => value)
          end
          opt.on("-c", "--critical CRITICAL", "CRITICAL Threshold") do |value|
            add_threshold(:default, :crit => value)
          end
          yield opt if block_given?
        end.parse!(args)
      end

      def check
        nagios_exit :unknown, "#{self.class.name}#check method should be implemented in the child class"
      end

    end
  end
end
