require 'spec_helper'

describe DateInputHandler do

  describe "Accepting string input" do
    describe "should be valid with valid dates" do
      it { should_accept("2012-12-25") }
      it { should_accept("2012-01-01") }
      it { should_accept("1999-1-1") }
      it { should_accept("25/12/2012") }
      it { should_accept("1/2/1999") }
    end

    describe "should be invalid with invalid dates" do
      it { should_reject("asdf") }
      it { should_reject("2012") }
      it { should_reject("asdf-11-11") }
      it { should_reject("junk") }
      it { should_reject("2012-01-") }
      it { should_reject("05-02-2011") } #TODO: should we allow this format?
      it { should_reject("05/22/2011") } #american date
      it { should_reject("30/2/2011") } #non existent
      it { should_reject("/22/2011") } #part missing
      it { should_reject("1//2011") } #part missing
      it { should_reject("12-1-1") } # reject years less than 1900
      it { should_reject("1899-1-1") } # reject years less than 1900
    end
  end

  describe "Accepting hash input" do
    it "should be valid when all 3 fields supplied" do
      dih = DateInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({day: "1", month: "12", year: "2000"}))
      dih.should be_valid
      dih.to_date.should eq(Date.parse("2000-12-01"))
    end

    it "should be invalid if a field is missing - month missing" do
      dih = DateInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({day: "1", month: "", year: "2000"}))
      dih.should_not be_valid
      raw = dih.to_raw
      raw.should be_a(Hash)
      raw[:day].should == "1"
      raw[:month].should == ""
      raw[:year].should == "2000"
    end

    it "should be invalid if a field is missing - year missing" do
      dih = DateInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({day: "1", month: "12", year: ""}))
      dih.should_not be_valid
      raw = dih.to_raw
      raw.should be_a(Hash)
      raw[:day].should == "1"
      raw[:month].should == "12"
      raw[:year].should == ""
    end

    it "should be invalid if date does not exist" do
      dih = DateInputHandler.new(ActiveSupport::HashWithIndifferentAccess.new ({day: "30", month: "2", year: "2000"}))
      dih.should_not be_valid
      raw = dih.to_raw
      raw.should be_a(Hash)
      raw[:day].should == "30"
      raw[:month].should == "2"
      raw[:year].should == "2000"
    end
  end

  describe "Accepting date input" do
    it "should accept it as is since it must be valid" do
      date = Date.parse("2011-12-12")
      dih = DateInputHandler.new(date)
      dih.should be_valid
      dih.to_date.should be(date)
    end
  end

  describe "Refuses to handle other types of input" do
    it "should throw an error on other types" do
      lambda { DateInputHandler.new(123) }.should raise_error
    end
  end

  describe "Refuses to answer to_raw if valid" do
    it "should throw an error" do
      dih = DateInputHandler.new("2012-12-22")
      lambda { dih.to_raw }.should raise_error
    end
  end

  describe "Refuses to answer to_date if invalid" do
    it "should throw an error" do
      dih = DateInputHandler.new("asdf")
      lambda { dih.to_date }.should raise_error
    end
  end

  def should_accept(string)
    dih = DateInputHandler.new(string)
    dih.should be_valid
    dih.to_date.should eq(Date.parse(string))
  end

  def should_reject(string)
    dih = DateInputHandler.new(string)
    dih.should_not be_valid
    dih.to_raw.should eq(string)
  end
end

