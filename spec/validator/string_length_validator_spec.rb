require 'spec_helper'

describe StringLengthValidator do

  describe "Validating a range" do
    let(:question) { Factory(:question, string_min: 5, string_max: 15) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "12345").should eq([true, nil])
      StringLengthValidator.validate(question, "123456").should eq([true, nil])
      StringLengthValidator.validate(question, "123456789012345").should eq([true, nil])
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1").should eq([false, "Answer should be between 5 and 15 characters"])
      StringLengthValidator.validate(question, "1234").should eq([false, "Answer should be between 5 and 15 characters"])
      StringLengthValidator.validate(question, "1234567890123456").should eq([false, "Answer should be between 5 and 15 characters"])
    end
  end

  describe "Validating a range with same min/max" do
    let(:question) { Factory(:question, string_min: 5, string_max: 5) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "12345").should eq([true, nil])
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1234").should eq([false, "Answer should be 5 characters"])
      StringLengthValidator.validate(question, "123456").should eq([false, "Answer should be 5 characters"])
    end
  end

  describe "Validating min only" do
    let(:question) { Factory(:question, string_min: 5, string_max: nil) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "12345").should eq([true, nil])
      StringLengthValidator.validate(question, "123456").should eq([true, nil])
      StringLengthValidator.validate(question, "123456789012345").should eq([true, nil])
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1").should eq([false, "Answer should be at least 5 characters"])
      StringLengthValidator.validate(question, "1234").should eq([false, "Answer should be at least 5 characters"])
    end
  end

  describe "Validating max only" do
    let(:question) { Factory(:question, string_min: nil, string_max: 15) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "1").should eq([true, nil])
      StringLengthValidator.validate(question, "1456").should eq([true, nil])
      StringLengthValidator.validate(question, "123456789012345").should eq([true, nil])
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1234567890123456").should eq([false, "Answer should be a maximum of 15 characters"])
    end
  end

  describe "Validating on a question with no range" do
    it "should always return true" do
      question = Factory(:question, string_min: nil, string_max: nil)
      StringLengthValidator.validate(question, "abc").should eq([true, nil])
    end
  end

  describe "Validating a nil or blank answer" do
    it "should always return true" do
      question = Factory(:question, string_min: 1, string_max: 5)
      #blank / nil are not considered errors
      StringLengthValidator.validate(question, nil).should eq([true, nil])
      StringLengthValidator.validate(question, "").should eq([true, nil])
    end
  end
end
