require 'spec_helper'

describe Response do
  describe "Associations" do
    it { should belong_to :survey }
    it { should belong_to :user }
    it { should belong_to :hospital }
    it { should have_many :answers }
  end
  describe "Validations" do
    it { should validate_presence_of :baby_code }
    it { should validate_presence_of :user }
    it { should validate_presence_of :survey_id }
  end

  describe "Determining status of a section" do
    before(:each) do
      @survey = Factory(:survey)
      @section1 = Factory(:section, survey: @survey)
      @section2 = Factory(:section, survey: @survey)

      @q1 = Factory(:question, section: @section1, mandatory: true, question_type: "Integer", number_min: 10)
      @q2 = Factory(:question, section: @section1, mandatory: true)
      @q3 = Factory(:question, section: @section1, mandatory: false)

      @q4 = Factory(:question, section: @section2, mandatory: true)
      @q5 = Factory(:question, section: @section2, mandatory: true)
      @q6 = Factory(:question, section: @section2, mandatory: false)

      @response = Factory(:response, survey: @survey)
    end

    it "should be 'not started' if no answers have been saved yet" do
      #initially, nothing is started
      @response.section_started?(@section1).should be_false
      @response.status_of_section(@section1).should eq("Not started")
      @response.section_started?(@section2).should be_false
      @response.status_of_section(@section2).should eq("Not started")
    end

    it "should be incomplete if at least one question is answered but not all mandatory questions are answered" do
      Factory(:answer, question: @q1, response: @response)
      @response.reload

      @response.section_started?(@section1).should be_true
      @response.status_of_section(@section1).should eq("Incomplete")
      @response.section_started?(@section2).should be_false
      @response.status_of_section(@section2).should eq("Not started")
    end

    it "should be complete once all mandatory questions are answered" do
      Factory(:answer, question: @q1, response: @response)
      Factory(:answer, question: @q2, response: @response)
      @response.reload

      @response.section_started?(@section1).should be_true
      @response.status_of_section(@section1).should eq("Complete")
    end

    it "should be incomplete if there's any range warnings present" do
      Factory(:answer, question: @q1, response: @response, answer_value: "5")
      Factory(:answer, question: @q2, response: @response)
      @response.reload

      @response.section_started?(@section1).should be_true
      @response.status_of_section(@section1).should eq("Incomplete")
    end

    it "should be incomplete if there's any format errors present" do
      pending
    end

    it "should be incomplete if there's any cross-question warnings present" do
      pending
    end
  end
end
