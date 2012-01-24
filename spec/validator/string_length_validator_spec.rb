require 'spec_helper'

describe StringLengthValidator do

  describe "Validating a range" do
    let(:question) { Factory(:question, string_min: 5, string_max: 15) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "12345").should be_true
      StringLengthValidator.validate(question, "123456").should be_true
      StringLengthValidator.validate(question, "123456789012345").should be_true
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1").should be_false
      StringLengthValidator.validate(question, "1234").should be_false
      StringLengthValidator.validate(question, "1234567890123456").should be_false
    end
  end

  describe "Validating min only" do
    let(:question) { Factory(:question, string_min: 5, string_max: nil) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "12345").should be_true
      StringLengthValidator.validate(question, "123456").should be_true
      StringLengthValidator.validate(question, "123456789012345").should be_true
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1").should be_false
      StringLengthValidator.validate(question, "1234").should be_false
    end
  end

  describe "Validating max only" do
    let(:question) { Factory(:question, string_min: nil, string_max: 15) }

    it "should return true if in range" do
      StringLengthValidator.validate(question, "1").should be_true
      StringLengthValidator.validate(question, "1456").should be_true
      StringLengthValidator.validate(question, "123456789012345").should be_true
    end

    it "should return false it outside range" do
      StringLengthValidator.validate(question, "1234567890123456").should be_false
    end
  end

  describe "Validating on a question with no range" do
    it "should always return true" do
      question = Factory(:question, string_min: nil, string_max: nil)
      StringLengthValidator.validate(question, "abc").should be_true
    end
  end

  describe "Validating a nil or blank answer" do
    it "should always return true" do
      question = Factory(:question, string_min: 1, string_max: 5)
      #TODO: tbc what the behaviour should be on nil answers
      StringLengthValidator.validate(question, nil).should be_true
      StringLengthValidator.validate(question, "").should be_true
    end
  end
end
