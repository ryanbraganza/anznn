require 'spec_helper'

describe Survey do
  describe "Associations" do
    it { should have_many :responses }
    it { should have_many :sections }
  end
  describe :ordered_questions do
    it "should retrieve questions ordered by section.order, question.order" do
      survey = Factory(:survey)
      s2 = Factory(:section, survey: survey, section_order: 2)
      s1 = Factory(:section, survey: survey, section_order: 1)
      q1b = Factory(:question, question: 'q1b', section: s1, question_order: 2)
      q1a = Factory(:question, question: 'q1a', section: s1, question_order: 1)
      q2a = Factory(:question, question: 'q2a', section: s2, question_order: 1)
      q2b = Factory(:question, question: 'q2b', section: s2, question_order: 2)

      expected = %w{q1a q1b q2a q2b}
      actual = survey.ordered_questions.map{|q| q.question }

      actual.should eq expected
    end
  end

  describe "Finding the next section after a given section" do
    it "should find the next one based on order" do
      survey1 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec3 = Factory(:section, survey: survey1, section_order: 3)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      survey1.section_id_after(sec1.id).should eq(sec2.id)
      survey1.section_id_after(sec2.id).should eq(sec3.id)
    end

    it "should raise error on last section" do
      survey1 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec3 = Factory(:section, survey: survey1, section_order: 3)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      lambda {survey1.section_id_after(sec3.id)}.should raise_error("Tried to call section_id_after on last section")
    end

    it "should raise error when section not found" do
      survey1 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      lambda{survey1.section_id_after(123434)}.should raise_error("Didn't find any section with id 123434 in this survey")
    end
  end
end
