require 'spec_helper'

describe Section do
  describe "Associations" do
    it { should belong_to :survey }
    it { should have_many :questions }
  end
  describe "Validations" do
    describe "order" do
      it { should validate_presence_of :order }
      it "is unique within a survey" do
        first_section = Factory :section
        second_section = Factory.build :section, survey: first_section.survey, order: first_section.order
        second_section.should_not be_valid

        section_in_another_survey = Factory.build :section, order: first_section.order
        section_in_another_survey.should be_valid
      end
    end
  end
end
