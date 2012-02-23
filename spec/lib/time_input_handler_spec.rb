require 'spec_helper'

describe TimeInputHandler do

  describe "Accepting string input" do
    describe "should be valid with valid times" do
      it { should_accept("0:00", 0, 0) }
      it { should_accept("0:01", 0, 1) }
      it { should_accept("1:00", 1, 0) }
      it { should_accept("01:00", 1, 0) }
      it { should_accept("11:59", 11, 59) }
      it { should_accept("12:33", 12, 33) }
      it { should_accept("23:44", 23, 44) }
      it { should_accept("23:59", 23, 59) }
    end

    describe "should be invalid with invalid times" do
      it { should_reject("asdf") }
      it { should_reject("2012") }
      it { should_reject("ab:22") }
      it { should_reject("1:a") }
      it { should_reject("1:60") }
      it { should_reject("24:00") }
      it { should_reject("24:01") }
    end
  end

  describe "Accepting hash input" do
    it "should be valid when both fields supplied" do
      dih = TimeInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({hour: "14", min: "59"}))
      dih.should be_valid
      dih.to_time.should eq(Time.utc(2000, 1, 1, 14, 59))
    end

    it "should be invalid if a field is missing - hour missing" do
      dih = TimeInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({hour: "", min: "59"}))
      dih.should_not be_valid
      raw = dih.to_raw
      raw.should be_a(Hash)
      raw[:hour].should == ""
      raw[:min].should == "59"
    end

    it "should be invalid if a field is missing - minute missing" do
      dih = TimeInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({hour: "14", min: ""}))
      dih.should_not be_valid
      raw = dih.to_raw
      raw.should be_a(Hash)
      raw[:hour].should == "14"
      raw[:min].should == ""
    end
  end

  describe "Accepting time input" do
    it "should accept it as is since it must be valid" do
      time = Time.now
      dih = TimeInputHandler.new(time)
      dih.should be_valid
      dih.to_time.should be(time)
    end
  end

  describe "Refuses to handle other types of input" do
    it "should throw an error on other types" do
      lambda { TimeInputHandler.new(123) }.should raise_error
    end
  end

  describe "Refuses to answer to_raw if valid" do
    it "should throw an error" do
      dih = TimeInputHandler.new("11:45")
      lambda { dih.to_raw }.should raise_error
    end
  end

  describe "Refuses to answer to_time if invalid" do
    it "should throw an error" do
      dih = TimeInputHandler.new("asdf")
      lambda { dih.to_time }.should raise_error
    end
  end

  def should_accept(string, h, m)
    dih = TimeInputHandler.new(string)
    dih.should be_valid, "Expected time string #{string} to be valid"
    dih.to_time.should eq(Time.utc(2000, 1, 1, h, m))
  end

  def should_reject(string)
    dih = TimeInputHandler.new(string)
    dih.should_not be_valid, "Expected time string #{string} to not be valid"
    dih.to_raw.should eq(string)
  end
end

