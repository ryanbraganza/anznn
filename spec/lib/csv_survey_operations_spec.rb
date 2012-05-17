require 'spec_helper'

include CsvSurveyOperations

def fqn(filename)
  # fully-qualified name.
  Rails.root.join('test_data', 'survey', filename)
end

def counts_should_eq_0(*models)
  counts = models.map {|m| m.count}
  counts.should eq ([0] * models.length)
end

describe CsvSurveyOperations do
  describe "create_survey" do

    let(:good_question_file) { fqn('survey_questions.csv') }
    let(:bad_question_file) { fqn('bad_questions.csv') }
    let(:good_options_file) { fqn('survey_options.csv') }
    let(:bad_options_file) { fqn('bad_options.csv') }
    let(:good_cqv_file) { fqn('cross_question_validations.csv') }
    let(:bad_cqv_file) { fqn('bad_cross_question_validations.csv') }

    it "works on good input" do
      s = create_survey('some_name', good_question_file, good_options_file, good_cqv_file)
      s.sections.count.should eq 2
      s.sections.first.questions.count.should eq 6
      s.sections.second.questions.count.should eq 3

      Section.find_by_name!('0').section_order.should eq 0
      Section.find_by_name!('1').section_order.should eq 1
    end

    it "should be transactional with a bad cqv file" do
      begin
        create_survey('some name', good_question_file, good_options_file, bad_cqv_file)
        raise 'not supposed to get here'
      rescue ActiveRecord::RecordNotFound
        # expected due to incorrect question code
      end
      counts_should_eq_0 Survey, Question, CrossQuestionValidation, Answer, Response, QuestionOption

    end

    it "should be transactional with a bad options file" do
      begin
        create_survey('some name', good_question_file, bad_options_file, good_cqv_file)
        raise 'not supposed to get here'
      rescue ActiveRecord::RecordInvalid
        # expected due to duplicate option order
      end
      counts_should_eq_0 Survey, Question, CrossQuestionValidation, Answer, Response, QuestionOption

    end
    it "should be transactional with a bad question file" do
      begin
        create_survey('some name', bad_question_file, good_options_file, good_cqv_file)
        raise 'not supposed to get here'
      rescue ActiveRecord::RecordInvalid
        # expected due to duplicate question order
      end
      counts_should_eq_0 Survey, Question, CrossQuestionValidation, Answer, Response, QuestionOption
    end

  end
end
