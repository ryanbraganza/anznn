require 'spec_helper'

describe CrossQuestionValidation do
  describe "Associations" do
    it { should belong_to :question }
    it { should belong_to :related_question }
  end
  describe "Validations" do
    it { should validate_presence_of :question_id }
    it { should validate_presence_of :related_question_id }
    it { should validate_presence_of :rule }
    it { should validate_presence_of :error_message }
    it "should validate that the rule is one of the allowed rules" do
      %w(date_gte date_gt date_lt date_lte).each do |value|
        should allow_value(value).for(:rule)
      end
      Factory.build(:cross_question_validation, rule: 'Blahblah').should_not be_valid
    end
  end
  describe "check" do
    describe "date_lte" do
      before :each do
        @survey = Factory :survey
        @section = Factory :section, survey: @survey
        @q1 = Factory :question, section: @section, question_type: 'Date'
        @q2 = Factory :question, section: @section, question_type: 'Date'
        @response = Factory :response, survey: @survey
        @error_message = 'not lte'

        Factory :cross_question_validation, rule: 'date_lte', question: @q1, related_question: @q2, error_message: @error_message
        
      end
      it "handles nils" do
        first = Factory :answer, response: @response, question: @q1, answer_value: {}
        second = Factory :answer, response: @response, question: @q2, answer_value: {}

        error_messages = CrossQuestionValidation.check first

        error_messages.should eq []
      end
      it "warns for gt" do
        first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
        second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

        error_messages = CrossQuestionValidation.check first

        error_messages.should eq [@error_message]
      end
      it "accepts lt" do
        first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
        second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

        error_messages = CrossQuestionValidation.check first

        error_messages.should eq []
      end
      it "accepts eq" do
        first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 2)
        second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

        error_messages = CrossQuestionValidation.check first

        error_messages.should eq []
      end
    end
  end
end
