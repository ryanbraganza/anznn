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
      CrossQuestionValidation::VALID_RULES.each do |value|
        should allow_value(value).for(:rule)
      end
      Factory.build(:cross_question_validation, rule: 'Blahblah').should_not be_valid
    end
  end
  describe "check" do
    describe "comparisons (using dates)" do
      before :each do
        @survey = Factory :survey
        @section = Factory :section, survey: @survey
        @q1 = Factory :question, section: @section, question_type: 'Date'
        @q2 = Factory :question, section: @section, question_type: 'Date'
        @response = Factory :response, survey: @survey
      end
      describe "date_lte" do
        before :each do
          @error_message = 'not lte'
          Factory :cross_question_validation, rule: 'comparison', operator: '<=', question: @q1, related_question: @q2, error_message: @error_message
        end
        it "handles nils" do
          first = Factory :answer, response: @response, question: @q1, answer_value: {}
          second = Factory :answer, response: @response, question: @q2, answer_value: {}

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects gt" do
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
      describe "date_gte" do
        before :each do
          @error_message = 'not gte'
          Factory :cross_question_validation, rule: 'comparison', operator: '>=', question: @q1, related_question: @q2, error_message: @error_message
        end
        it "handles nils" do
          first = Factory :answer, response: @response, question: @q1, answer_value: {}
          second = Factory :answer, response: @response, question: @q2, answer_value: {}

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "accepts gt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects lt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
        it "accepts eq" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 2)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
      end
      describe "date_gt" do
        before :each do
          @error_message = 'not gt'
          Factory :cross_question_validation, rule: 'comparison', operator: '>', question: @q1, related_question: @q2, error_message: @error_message
        end
        it "handles nils" do
          first = Factory :answer, response: @response, question: @q1, answer_value: {}
          second = Factory :answer, response: @response, question: @q2, answer_value: {}

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "accepts gt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects lt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
        it "rejects eq" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 2)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
      end
      describe "date_lt" do
        before :each do
          @error_message = 'not lt'
          Factory :cross_question_validation, rule: 'comparison', operator: '<', question: @q1, related_question: @q2, error_message: @error_message
        end
        it "handles nils" do
          first = Factory :answer, response: @response, question: @q1, answer_value: {}
          second = Factory :answer, response: @response, question: @q2, answer_value: {}

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects gt" do
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
        it "rejects eq" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 2)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
      end
      describe "date_eq" do
        before :each do
          @error_message = 'not eq'
          Factory :cross_question_validation, rule: 'comparison', operator: '==', question: @q1, related_question: @q2, error_message: @error_message
        end
        it "handles nils" do
          first = Factory :answer, response: @response, question: @q1, answer_value: {}
          second = Factory :answer, response: @response, question: @q2, answer_value: {}

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects gt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
        it "rejects lt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
        it "accepts eq" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 2)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
      end
      describe "date_ne" do
        before :each do
          @error_message = 'are eq'
          Factory :cross_question_validation, rule: 'comparison', operator: '!=', question: @q1, related_question: @q2, error_message: @error_message
        end
        it "handles nils" do
          first = Factory :answer, response: @response, question: @q1, answer_value: {}
          second = Factory :answer, response: @response, question: @q2, answer_value: {}

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "accepts gt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "accepts lt" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects eq" do
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 2)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
      end
      describe "comparisons with offsets function normally" do
        #This isn't much to test here: We're utilising the other class' ability to use +/-, so as long
        # As it works for one case involving a 'complex' type, that's good enough.
        before :each do
          @error_message = 'not eq'
        end
        it "accepts X eq Y (offset +1) when Y = X-1" do
          Factory :cross_question_validation, rule: 'comparison', operator: '==', question: @q1, related_question: @q2, error_message: @error_message, constant: 1
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 2)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects X eq Y (offset +1) when Y = X" do
          Factory :cross_question_validation, rule: 'comparison', operator: '==', question: @q1, related_question: @q2, error_message: @error_message, constant: 1
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 1)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
        it "accepts X eq Y (offset -1) when Y = X+1" do
          Factory :cross_question_validation, rule: 'comparison', operator: '==', question: @q1, related_question: @q2, error_message: @error_message, constant: -1
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 3)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 4)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq []
        end
        it "rejects X eq Y (offset -1) when Y = X" do
          Factory :cross_question_validation, rule: 'comparison', operator: '==', question: @q1, related_question: @q2, error_message: @error_message, constant: -1
          first = Factory :answer, response: @response, question: @q1, answer_value: Date.new(2012, 2, 1)
          second = Factory :answer, response: @response, question: @q2, answer_value: Date.new(2012, 2, 1)

          error_messages = CrossQuestionValidation.check first

          error_messages.should eq [@error_message]
        end
      end
    end
  end
end
