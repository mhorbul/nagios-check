require 'spec_helper'

describe Nagios::Plugin::Threshold do

  it "should have warn and crit Ranges" do
    threshold = Nagios::Plugin::Threshold.new(:warn => "10:20", :crit => "30:40")
    threshold.warn.should be_a(Nagios::Plugin::Range)
    threshold.crit.should be_a(Nagios::Plugin::Range)
  end

  it "should set thresholds" do
    threshold = Nagios::Plugin::Threshold.new
    threshold.warn.should be_nil
    threshold.crit.should be_nil
    threshold.warn("10:20")
    threshold.warn.should be_a(Nagios::Plugin::Range)
    threshold.crit("30:")
    threshold.crit.should be_a(Nagios::Plugin::Range)
  end

  it "should not set threshold when value is not valid" do
    threshold = Nagios::Plugin::Threshold.new
    threshold.warn.should be_nil
    threshold.crit.should be_nil
    threshold.warn("10::")
    threshold.crit(false)
    threshold.warn.should be_nil
    threshold.crit.should be_nil
  end

  context "#get_status" do

    let(:crit_range) { double }
    let(:warn_range) { double }
    let(:threshold) { Nagios::Plugin::Threshold.new(:warn => "10", :crit => "20") }

    before do
      threshold.stub(:crit).and_return(crit_range)
      threshold.stub(:warn).and_return(warn_range)
    end

    it "should return WARNING status when crit range is not defined" do
      threshold.stub(:crit).and_return(nil)
      crit_range.should_not_receive(:check_range)
      warn_range.should_receive(:check_range).with(15).and_return(true)
      threshold.get_status(15).should eq(Nagios::WARNING)
    end

    it "should return WARNING threshold status" do
      crit_range.should_receive(:check_range).with(15).and_return(false)
      warn_range.should_receive(:check_range).with(15).and_return(true)
      threshold.get_status(15).should eq(Nagios::WARNING)
    end

    it "should return CRITICAL threshold status" do
      crit_range.should_receive(:check_range).with(25).and_return(true)
      warn_range.should_not_receive(:check_range)
      threshold.get_status(25).should eq(Nagios::CRITICAL)
    end

    it "should return OK status when neither crit nor warn ranges are defined" do
      threshold.stub(:warn).and_return(nil)
      threshold.stub(:crit).and_return(nil)
      crit_range.should_not_receive(:check_range)
      warn_range.should_not_receive(:check_range)
      threshold.get_status(15).should eq(Nagios::OK)
    end

    it "should return OK threshold status" do
      crit_range.should_receive(:check_range).with(5).and_return(false)
      warn_range.should_receive(:check_range).with(5).and_return(false)
      threshold.get_status(5).should eq(Nagios::OK)
    end
  end
end
