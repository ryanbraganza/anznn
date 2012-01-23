require 'spec_helper'

describe QuestionOption do
  describe "Validations" do
    it { should validate_presence_of(:question_id) }
    it { should validate_presence_of(:option_value) }
    it { should validate_presence_of(:label) }
    it { should validate_presence_of(:option_order) }

    it "should validate that order is unique within a question" do
      first = Factory(:question_option)
      second = Factory.build(:question_option, question: first.question, option_order: first.option_order)
      second.should_not be_valid

      under_different_question = Factory.build(:question_option, question: Factory(:question), option_order: first.option_order)
      under_different_question.should be_valid
    end
  end
end
