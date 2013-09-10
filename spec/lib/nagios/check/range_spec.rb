require 'spec_helper'

describe Nagios::Check::Range do

  it "should raise error when range is not a string" do
    lambda { Nagios::Check::Range.new(:x) }.should raise_error(TypeError)
    lambda { Nagios::Check::Range.new(nil) }.should raise_error(TypeError)
    lambda { Nagios::Check::Range.new(true) }.should raise_error(TypeError)
  end

  it "should raise error when range is bad formatted" do
    lambda { Nagios::Check::Range.new("abc") }.should raise_error(TypeError)
    lambda { Nagios::Check::Range.new("10::") }.should raise_error(TypeError)
    lambda { Nagios::Check::Range.new("-10::") }.should raise_error(TypeError)
  end

  context "parse string value correctly" do

    it "should convert string check value into float" do
      range = Nagios::Check::Range.new("10") # 0 <= x >= 10
      range.check_range("10").should  eq(false)
      range.check_range("5.5").should   eq(false)
      range.check_range("0").should   eq(false)
      range.check_range("20").should  eq(true) # > 10
      range.check_range("-10").should eq(true) # < 0
    end

    it "should convert numeric range value into string" do
      range = Nagios::Check::Range.new(10) # 0 <= x >= 10
      range.check_range(10).should  eq(false)
      range.check_range(5).should   eq(false)
      range.check_range(0).should   eq(false)
      range.check_range(20).should  eq(true) # > 10
      range.check_range(-10).should eq(true) # < 0
    end

    it "should check range '10'" do
      range = Nagios::Check::Range.new("10") # 0 <= x >= 10
      range.check_range(10).should  eq(false)
      range.check_range(5).should   eq(false)
      range.check_range(0).should   eq(false)
      range.check_range(20).should  eq(true) # > 10
      range.check_range(-10).should eq(true) # < 0
    end

    it "should check range '10:20'" do
      range = Nagios::Check::Range.new("10:20") # 10 <= x >= 20
      range.check_range(10).should  eq(false)
      range.check_range(15).should  eq(false)
      range.check_range(20).should  eq(false)
      range.check_range(5).should   eq(true) # < 10
      range.check_range(30).should  eq(true) # > 20
      range.check_range(-10).should eq(true) # < 0
    end

    it "should check negative range '-10:20'" do
      range = Nagios::Check::Range.new("-10:20") # 10 <= x >= 20
      range.check_range(10).should  eq(false)
      range.check_range(15).should  eq(false)
      range.check_range(20).should  eq(false)
      range.check_range(-10).should eq(false)
      range.check_range(-50).should   eq(true) # < -10
      range.check_range(30).should  eq(true) # > 20
    end

    it "should check range '10:'" do
      range = Nagios::Check::Range.new("10:") # x >= 10
      range.check_range(10).should  eq(false)
      range.check_range(20).should  eq(false)
      range.check_range(5).should   eq(true) # < 10
      range.check_range(-10).should eq(true) # < 0
    end

    it "should check range '~:10'" do
      range = Nagios::Check::Range.new("~:10") # x <= 10
      range.check_range(10).should  eq(false)
      range.check_range(0).should   eq(false)
      range.check_range(5).should   eq(false)
      range.check_range(-10).should eq(false)
      range.check_range(20).should  eq(true) # > 10
    end

    it "should check range '@10:20'" do
      range = Nagios::Check::Range.new("@10:20") # x < 10 && 20 > x
      range.check_range(0).should   eq(false)
      range.check_range(5).should   eq(false)
      range.check_range(-10).should eq(false)
      range.check_range(30).should  eq(false)
      range.check_range(10).should  eq(true) # = 10
      range.check_range(20).should  eq(true) # = 20
      range.check_range(15).should  eq(true) # > 10 && < 20
    end

    it "should check range with float numbers '@10.5:20'" do
      range = Nagios::Check::Range.new("@10.5:20") # x < 10.5 && 20 > x
      range.check_range(0).should     eq(false)
      range.check_range(5).should     eq(false)
      range.check_range(-10).should   eq(false)
      range.check_range(30).should    eq(false)
      range.check_range(10).should    eq(false)
      range.check_range(10.4).should  eq(false)

      range.check_range(10.5).should  eq(true) # = 10.5
      range.check_range(20).should    eq(true) # = 20
      range.check_range(15).should    eq(true) # > 10 && < 20
    end

  end

end
