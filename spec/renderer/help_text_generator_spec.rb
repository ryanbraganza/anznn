require 'spec_helper'

describe HelpTextGenerator do
  describe "Generating format hint for display" do
    it "should return nil for Date, Time and Choice type questions" do
      [Question::TYPE_DATE, Question::TYPE_TIME, Question::TYPE_CHOICE].each do |type|
        q = Factory(:question, question_type: type)
        HelpTextGenerator.new(q).help_text.should be_nil
      end
    end

    describe "Text type questions" do
      it "should return simple 'text' hint for question without range limits" do
        help_text(question_type: Question::TYPE_TEXT).should eq("Text")
      end
      it "should return hint with size details for question with range limits (both min and max)" do
        help_text(question_type: Question::TYPE_TEXT, string_min: 10, string_max: 25).should eq("Text between 10 and 25 characters long")
      end
      it "should return hint with size details for question with range limits (both min and max the same)" do
        help_text(question_type: Question::TYPE_TEXT, string_min: 10, string_max: 10).should eq("Text 10 characters long")
      end
      it "should return hint with size details for question with range limits (min only)" do
        help_text(question_type: Question::TYPE_TEXT, string_min: 10, string_max: nil).should eq("Text at least 10 characters long")
      end
      it "should return hint with size details for question with range limits (max only)" do
        help_text(question_type: Question::TYPE_TEXT, string_min: nil, string_max: 25).should eq("Text up to 25 characters long")
      end
    end

    describe "Integer type questions" do
      it "should return simple 'number' hint for question without range limits" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: nil, number_max: nil, number_unknown: nil).should eq("Number")
      end
      it "should return hint with size details for question with range limits (both min and max)" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: 10, number_max: 25, number_unknown: nil).should eq("Number between 10 and 25")
      end
      it "should return hint with size details for question with range limits (min only)" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: 10, number_max: nil, number_unknown: nil).should eq("Number at least 10")
      end
      it "should return hint with size details for question with range limits (max only)" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: nil, number_max: 25, number_unknown: nil).should eq("Number up to 25")
      end
      it "should return hint with size details for question with range limits (both min and max) with unknown" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: 10, number_max: 25, number_unknown: 99).should eq("Number between 10 and 25 or 99 for unknown")
      end
      it "should return hint with size details for question with range limits (min only) with unknown" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: 10, number_max: nil, number_unknown: 99).should eq("Number at least 10 or 99 for unknown")
      end
      it "should return hint with size details for question with range limits (max only) with unknown" do
        help_text(question_type: Question::TYPE_INTEGER, number_min: nil, number_max: 25, number_unknown: 99).should eq("Number up to 25 or 99 for unknown")
      end
    end

    describe "Decimal type questions" do
      it "should return simple 'number' hint for question without range limits" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: nil, number_max: nil, number_unknown: nil).should eq("Decimal number")
      end
      it "should return hint with size details for question with range limits (both min and max)" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: 10, number_max: 25.3, number_unknown: nil).should eq("Decimal number between 10 and 25.3")
      end
      it "should return hint with size details for question with range limits (min only)" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: 10, number_max: nil, number_unknown: nil).should eq("Decimal number at least 10")
      end
      it "should return hint with size details for question with range limits (max only)" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: nil, number_max: 25.3, number_unknown: nil).should eq("Decimal number up to 25.3")
      end
      it "should return hint with size details for question with range limits (both min and max) with unknown" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: 10, number_max: 25.3, number_unknown: 99).should eq("Decimal number between 10 and 25.3 or 99 for unknown")
      end
      it "should return hint with size details for question with range limits (min only) with unknown" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: 10, number_max: nil, number_unknown: 99).should eq("Decimal number at least 10 or 99 for unknown")
      end
      it "should return hint with size details for question with range limits (max only) with unknown" do
        help_text(question_type: Question::TYPE_DECIMAL, number_min: nil, number_max: 25.3, number_unknown: 99).should eq("Decimal number up to 25.3 or 99 for unknown")
      end
    end
  end
end

def help_text(question_attrs)
  q = Factory(:question, question_attrs)
  HelpTextGenerator.new(q).help_text
end