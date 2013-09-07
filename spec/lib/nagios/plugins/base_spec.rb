require 'spec_helper'

describe Nagios::Plugin::Base do

  class TestPlugin < Nagios::Plugin::Base

    def parse(args)
      option_parser(args) do |opt|
        opt.on("-H", "--host HOST", "Hostname or IP address") do |value|
          @options[:host] = value
        end
        opt.on("-P", "--port PORT", "TCP Port of the service") do |value|
          @options[:port] = value
        end
      end
    end

  end

  context "#nagios_exit" do

    it "should exit with unknown status when exit code is not found." do
      plugin = Nagios::Plugin::Base.new
      begin
        message = capture_output do
          plugin.nagios_exit(:foo, "it works!")
        end
      rescue SystemExit => e
        e.status.should eq(Nagios::UNKNOWN)
      end
      message.should eq("UNKNOWN - exit code 'foo' is not found.\n")
    end

    it "should exit with OK status" do
      plugin = Nagios::Plugin::Base.new
      begin
        message = capture_output do
          plugin.nagios_exit(Nagios::OK, "it works!\n")
        end
      rescue SystemExit => e
        e.status.should eq(Nagios::OK)
      end
      message.should eq("OK - it works!\n")
    end

    it "should exit with WARNING status" do
      plugin = Nagios::Plugin::Base.new
      begin
        message = capture_output do
          plugin.nagios_exit(:warning, "does not work.")
        end
      rescue SystemExit => e
        e.status.should eq(Nagios::WARNING)
      end
      message.should eq("WARNING - does not work.\n")
    end

    it "should exit with Unknown status when check method raises error" do
      plugin = Nagios::Plugin::Base.new
      begin
        message = capture_output do
          plugin.run
        end
      rescue SystemExit => e
        e.status.should eq(Nagios::UNKNOWN)
      end
      message.should eq("UNKNOWN - Nagios::Plugin::Base#check method should be implemented in the child class\n")
    end

  end

  context "options parser" do

    it "should have threshold" do
      plugin = Nagios::Plugin::Base.new
      plugin.threshold.should be_a(Nagios::Plugin::Threshold)
    end

    it "should parse options and setup thresholds" do
      plugin = Nagios::Plugin::Base.new
      plugin.threshold.should_receive(:crit).with("20")
      plugin.threshold.should_receive(:warn).with("10")
      plugin.parse(["-w", "10", "-c", "20"])
    end

    it "should parse long options and setup thresholds" do
      plugin = Nagios::Plugin::Base.new
      plugin.threshold.should_receive(:crit).with("@20:40")
      plugin.threshold.should_receive(:warn).with("10:20")
      plugin.parse(["--warning=10:20", "--critical=@20:40"])
    end

    it "should parse other options defined in the child class" do
      plugin = TestPlugin.new
      plugin.threshold.should_receive(:crit).with("@20:40")
      plugin.threshold.should_receive(:warn).with("10:20")
      plugin.parse(["--warning=10:20", "--critical=@20:40", "-H", "domain.com", "--port=80"])
      plugin.options[:host] = "domain.com"
      plugin.options[:port] = 80
    end

  end

end
