#!/usr/bin/env -- ruby
#
# Usage: check_file_age --file /path/to/file -w 3600 -c 4800
#
$LOAD_PATH.push './lib'

require 'nagios'

module Nagios
  module Check
    class FileAge < Base

      def parse(args)
        option_parser(args) do |opt|
          opt.on("-f", "--file FILE_PATH", "Path to file") do |value|
            @options[:file] = value
          end
        end
      end

      def check
        age = file_age
        code = check_threshold(age)
        message = "File is too old."
        message = "File has been updated #{age} sec. ago" unless code == Nagios::OK
        nagios_exit(code, message)
      end

      def file_age
        nagios_exit(:critical, "File does not exit") unless File.exist?(options[:file].to_s)
        Time.now - File.mtime(options[:file])
      end

    end
  end
end

nagios = Nagios::Check::FileAge.new
nagios.run(ARGV)
