require 'spec_helper'

describe Survey do
  describe "Associations" do
    it { should have_many :responses }
    it { should have_many :sections }
  end
  describe :ordered_questions do
    it "should retrieve questions ordered by section.order, question.order" do
      survey = Factory(:survey)
      s2 = Factory(:section, survey: survey, order: 2)
      s1 = Factory(:section, survey: survey, order: 1)
      q1b = Factory(:question, question: 'q1b', section: s1, order: 2)
      q1a = Factory(:question, question: 'q1a', section: s1, order: 1)
      q2a = Factory(:question, question: 'q2a', section: s2, order: 1)
      q2b = Factory(:question, question: 'q2b', section: s2, order: 2)

      expected = %w{q1a q1b q2a q2b}
      actual = survey.ordered_questions.map{|q| q.question }

      expected.should eq actual
    end
  end
end
