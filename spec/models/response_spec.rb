require 'spec_helper'

describe Response do
  describe "Associations" do
    it { should belong_to :survey }
    it { should belong_to :user }
    it { should have_many :answers }
  end
  describe "Validations" do
    it { should validate_presence_of :baby_code }
    it { should validate_presence_of :user }
    it { should validate_presence_of :survey_id }
  end

  describe "Section started? method" do
    it "should return false if no answers saved within section" do
      survey = Factory(:survey)
      section1 = Factory(:section, survey: survey)
      section2 = Factory(:section, survey: survey)
      q1 = Factory(:question, section: section1)
      q2 = Factory(:question, section: section1)
      q3 = Factory(:question, section: section2)
      q4 = Factory(:question, section: section2)

      response = Factory(:response, survey: survey)

      #initially, nothing is started
      response.section_started?(section1).should be_false
      response.section_started?(section2).should be_false

      Factory(:answer, question: q1, response: response)
      response.reload
      response.section_started?(section1).should be_true
      response.section_started?(section2).should be_false

      Factory(:answer, question: q2, response: response)
      Factory(:answer, question: q3, response: response)
      response.reload
      response.section_started?(section1).should be_true
      response.section_started?(section2).should be_true
    end
  end
end
