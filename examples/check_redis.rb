#!/usr/bin/env -- ruby
#
# Usage: check_redis --host domain.com -p 9379 -w 80 -c 90
#
$LOAD_PATH.push './lib'

require 'redis'
require 'nagios'

module Nagios
  module Plugin
    class Redis < Base

      def default_options
        {
          :host => "127.0.0.1",
          :port => 6379
        }
      end

      def parse(args)
        option_parser(args) do |opt|
          opt.on("-p", "--port PORT", "Redis server port (default: 6379)") do |value|
            @options[:port] = Integer(value)
          end
          opt.on("-H", "--host HOST_OR_IP", "Redis server host or ip address (default: 127.0.0.1)") do |value|
            @options[:host] = value
          end
        end
      end

      def check
        begin
          data = redis.info
        rescue => e
          nagios_exit(:critical, "Can't fetch info from redis server.: #{e}")
        end

        message = "Everything is OK"
        code = Nagios::OK

        check_slave(data, code, message) if data['role'] == 'slave'

        nagios_exit(code, message)
      end

      def check_slave(data, code, message)
        code = check_threshold(data['master_last_io_seconds_ago'])
        message = "redis replication is late #{data['master_last_io_seconds_ago']} s" unless code == Nagios::OK

        if Integer(data['master_sync_in_progress']) != 0
          message = "redis replication sync is in progress"
          code = Nagios::CRITICAL
        end
        nagios_exit(code, message)
      end

      def redis
        begin
          @redis ||= ::Redis.new(:host => options[:host], :port => options[:port])
        rescue => e
          nagios_exit(:critical, "Can't connection to #{options[:host]}:#{options[:port]}: #{e}")
        end
      end

    end
  end
end

nagios = Nagios::Plugin::Redis.new
nagios.run(ARGV)
