require 'spec_helper'

describe "Special Rules" do
  pending "shouldn't call 'present' on an answer" do
    survey = Factory.create(:survey)
    section = Factory.create(:section, survey: survey)
    response = Factory.create(:response, survey: survey)
    o2_36wk = Factory.create(:question, section: section, code: 'O2_36wk_', question_type: Question::TYPE_INTEGER)
    gest = Factory.create(:question, section: section, code: SpecialRules::GEST_CODE, question_type: Question::TYPE_INTEGER)
    wght = Factory.create(:question, section: section, code: SpecialRules::WGHT_CODE, question_type: Question::TYPE_INTEGER)

    survey.send(:populate_question_hash)

    cqv = Factory.create(:cross_question_validation, rule: 'special_o2_a', related_question: nil, question: o2_36wk, error_message: 'If O2_36wk_ is -1 and (Gest must be <32 or Wght must be <1500) then (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36' )

    gest_answer = Factory.create(:answer, question: gest, response: response, answer_value: CrossQuestionValidation::GEST_LT - 1)
    a = Factory.create(:answer, question: o2_36wk, response: response, answer_value: '-1')
    raise "#{a.response.answers.inspect} #{a.response.answers.count}"  # gives "[] 2" ????

    warnings = CrossQuestionValidation.check(a)
    warnings.should be_present
  end
end
