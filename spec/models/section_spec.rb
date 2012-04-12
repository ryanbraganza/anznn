require 'spec_helper'

describe Section do
  describe "Associations" do
    it { should belong_to :survey }
    it { should have_many :questions }
  end
  describe "Validations" do
    it { should validate_presence_of(:name) }
    describe "order" do
      it { should validate_presence_of :section_order }
      it "is unique within a survey" do
        first_section = Factory :section
        second_section = Factory.build :section, survey: first_section.survey, section_order: first_section.section_order
        second_section.should_not be_valid

        section_in_another_survey = Factory.build :section, section_order: first_section.section_order
        section_in_another_survey.should be_valid
      end
    end
  end

  describe "Am I the last section method" do
    it "should return true only for the section with highest index" do
      survey1 = Factory(:survey)
      survey2 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec3 = Factory(:section, survey: survey1, section_order: 3)
      sec4 = Factory(:section, survey: survey2, section_order: 4)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      sec1.last?.should be_false
      sec2.last?.should be_false
      sec3.last?.should be_true
      sec4.last?.should be_true
    end
  end
end
