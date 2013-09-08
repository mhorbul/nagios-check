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

  let(:plugin) { Nagios::Plugin::Base.new }
  let(:threshold) { double }
  before do
    Nagios::Plugin::Threshold.stub(:new).and_return(threshold)
    threshold.stub(:crit)
    threshold.stub(:warn)
  end

  it "should check default threshold when name is not provided" do
    plugin.add_threshold(:default, :warn => "10", :crit => "20")
    plugin.thresholds[:default].should_receive(:get_status).with(25)
    plugin.check_threshold(25)
  end

  it "should check  threshold by name" do
    plugin.add_threshold(:custom, :warn => "10", :crit => "20")
    plugin.thresholds[:custom].should_receive(:get_status).with(25)
    plugin.check_threshold(:custom => 25)
  end

  it "should raise error when check unknown threshold" do
    lambda { plugin.check_threshold(:unknown => 25) }.should raise_exception(Exception) { |e| e.to_s.should eq("threshold 'unknown' does not exit") }
  end

  it "should add threshold" do
    threshold.should_receive(:warn).with("10")
    threshold.should_receive(:crit).with("20")
    plugin.add_threshold(:custom, :warn => "10", :crit => "20")
    plugin.thresholds[:custom].should eq(threshold)
  end

  context "#nagios_exit" do

    it "should exit with unknown status when exit code is not found." do
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

    it "should have default threshold" do
      plugin.thresholds.should be_empty
      threshold.stub(:warn)
      threshold.stub(:crit)
      plugin.parse(["-w", "10", "-c", "20"])
      plugin.thresholds[:default].should eq(threshold)
    end

    it "should parse options and setup thresholds" do
      threshold.should_receive(:crit).with("20")
      threshold.should_receive(:warn).with("10")
      plugin.parse(["-w", "10", "-c", "20"])
    end

    it "should parse long options and setup thresholds" do
      threshold.should_receive(:crit).with("@20:40")
      threshold.should_receive(:warn).with("10:20")
      plugin.parse(["--warning=10:20", "--critical=@20:40"])
    end

    it "should parse other options defined in the child class" do
      plugin = TestPlugin.new
      threshold.should_receive(:crit).with("@20:40")
      threshold.should_receive(:warn).with("10:20")
      plugin.parse(["--warning=10:20", "--critical=@20:40", "-H", "domain.com", "--port=80"])
      plugin.options[:host] = "domain.com"
      plugin.options[:port] = 80
    end

  end

end
