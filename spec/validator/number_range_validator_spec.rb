require 'spec_helper'

describe NumberRangeValidator do

  describe "Validating a range with an unknown value" do
    let(:question) { Factory(:question, number_min: 5, number_max: 15, number_unknown: 99) }

    it "should return true if in range" do
      NumberRangeValidator.validate(question, 5).should be_true
      NumberRangeValidator.validate(question, 5.1).should be_true
      NumberRangeValidator.validate(question, 10).should be_true
      NumberRangeValidator.validate(question, 15).should be_true
    end

    it "should return false it outside range" do
      NumberRangeValidator.validate(question, 4).should be_false
      NumberRangeValidator.validate(question, 4.9).should be_false
      NumberRangeValidator.validate(question, 15.1).should be_false
      NumberRangeValidator.validate(question, 16).should be_false
      NumberRangeValidator.validate(question, -10).should be_false
    end

    it "should return true if equal to unknown value" do
      NumberRangeValidator.validate(question, 99).should be_true
    end
  end

  describe "Validating a range without an unknown value" do
    let(:question) { Factory(:question, number_min: 5, number_max: 15, number_unknown: nil) }

    it "should return true if in range" do
      NumberRangeValidator.validate(question, 5).should be_true
      NumberRangeValidator.validate(question, 5.1).should be_true
      NumberRangeValidator.validate(question, 10).should be_true
      NumberRangeValidator.validate(question, 15).should be_true
    end

    it "should return false it outside range" do
      NumberRangeValidator.validate(question, 4).should be_false
      NumberRangeValidator.validate(question, 4.9).should be_false
      NumberRangeValidator.validate(question, 15.1).should be_false
      NumberRangeValidator.validate(question, 16).should be_false
      NumberRangeValidator.validate(question, -10).should be_false
    end
  end

  describe "Validating min only with an unknown value" do
    let(:question) { Factory(:question, number_min: 5, number_max: nil, number_unknown: 1) }

    it "should return true if in range" do
      NumberRangeValidator.validate(question, 5).should be_true
      NumberRangeValidator.validate(question, 5.1).should be_true
      NumberRangeValidator.validate(question, 10).should be_true
      NumberRangeValidator.validate(question, 111111111).should be_true
    end

    it "should return false it outside range" do
      NumberRangeValidator.validate(question, 4).should be_false
      NumberRangeValidator.validate(question, 4.9).should be_false
      NumberRangeValidator.validate(question, -10).should be_false
    end

    it "should return true if equal to unknown value" do
      NumberRangeValidator.validate(question, 1).should be_true
    end
  end

  describe "Validating min only without an unknown value" do
    let(:question) { Factory(:question, number_min: 5, number_max: nil, number_unknown: nil) }

    it "should return true if in range" do
      NumberRangeValidator.validate(question, 5).should be_true
      NumberRangeValidator.validate(question, 5.1).should be_true
      NumberRangeValidator.validate(question, 10).should be_true
      NumberRangeValidator.validate(question, 111111111).should be_true
    end

    it "should return false it outside range" do
      NumberRangeValidator.validate(question, 4).should be_false
      NumberRangeValidator.validate(question, 4.9).should be_false
      NumberRangeValidator.validate(question, -10).should be_false
    end
  end

  describe "Validating max only with an unknown value" do
    let(:question) { Factory(:question, number_min: nil, number_max: 15, number_unknown: 1) }

    it "should return true if in range" do
      NumberRangeValidator.validate(question, 5).should be_true
      NumberRangeValidator.validate(question, 14.9).should be_true
      NumberRangeValidator.validate(question, 10).should be_true
      NumberRangeValidator.validate(question, -1111111111).should be_true
    end

    it "should return false it outside range" do
      NumberRangeValidator.validate(question, 15.1).should be_false
      NumberRangeValidator.validate(question, 20).should be_false
      NumberRangeValidator.validate(question, 11111111).should be_false
    end

    it "should return true if equal to unknown value" do
      NumberRangeValidator.validate(question, 1).should be_true
    end
  end

  describe "Validating max only without an unknown value" do
    let(:question) { Factory(:question, number_min: nil, number_max: 15, number_unknown: nil) }

    it "should return true if in range" do
      NumberRangeValidator.validate(question, 5).should be_true
      NumberRangeValidator.validate(question, 14.9).should be_true
      NumberRangeValidator.validate(question, 10).should be_true
      NumberRangeValidator.validate(question, -1111111111).should be_true
    end

    it "should return false it outside range" do
      NumberRangeValidator.validate(question, 15.1).should be_false
      NumberRangeValidator.validate(question, 20).should be_false
      NumberRangeValidator.validate(question, 11111111).should be_false
    end
  end

  describe "Validating on a question with no range" do
    it "should always return true" do
      question = Factory(:question, number_min: nil, number_max: nil)
      NumberRangeValidator.validate(question, 2344).should be_true
    end
  end

  describe "Validating a nil answer" do
    it "should always return true" do
      question = Factory(:question, number_min: 1, number_max: 5)
      #TODO: tbc what the behaviour should be on nil answers
      NumberRangeValidator.validate(question, nil).should be_true
    end
  end
end
