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

  describe "status" do
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
      @q7 = Factory(:question, section: @section2, mandatory: false, question_type: "Integer", number_max: 15)

      @response = Factory(:response, survey: @survey)
    end
    describe "of a response" do
      it "not started" do
        @response.status.should eq "Not started"
      end
      it "incomplete section 1" do
        Factory(:answer, response: @response, question: @q1, integer_answer: 3)

        @response.status.should eq "Incomplete"
      end
      it "incomplete section 2" do
        Factory(:answer, response: @response, question: @q7, integer_answer: 16)

        @response.status.should eq "Incomplete"
      end
      it "Complete with warnings" do
        Factory(:answer, question: @q1, response: @response, integer_answer: 9)
        Factory(:answer, question: @q2, response: @response)
        Factory(:answer, question: @q4, response: @response)
        Factory(:answer, question: @q5, response: @response)

        @response.status.should eq "Complete with warnings"
      end
      it "Complete with no warnings" do
        Factory(:answer, question: @q1, response: @response, integer_answer: 11)
        Factory(:answer, question: @q2, response: @response)
        Factory(:answer, question: @q4, response: @response)
        Factory(:answer, question: @q5, response: @response)

        @response.status.should eq "Complete"
      end
      it "should recognise section 2 as incomplete and mark the response as incomplete even if section 1 is complete" do
        Factory(:answer, question: @q1, response: @response, integer_answer: 11)
        Factory(:answer, question: @q2, response: @response)

        @response.status.should eq "Incomplete"
      end
    end
    describe "of a section" do

      it "should be 'not started' if no answers have been saved yet" do
        #initially, nothing is started
        @response.section_started?(@section1).should be_false
        @response.status_of_section(@section1).should eq("Not started")
        @response.section_started?(@section2).should be_false
        @response.status_of_section(@section2).should eq("Not started")
      end

      it "should be incomplete if at least one question is answered but not all mandatory questions are answered" do
        Factory(:answer, question: @q1, response: @response)

        @response.section_started?(@section1).should be_true
        @response.status_of_section(@section1).should eq("Incomplete")
        @response.section_started?(@section2).should be_false
        @response.status_of_section(@section2).should eq("Not started")
      end

      it "should be complete once all mandatory questions are answered" do
        Factory(:answer, question: @q1, response: @response)
        Factory(:answer, question: @q2, response: @response)

        @response.section_started?(@section1).should be_true
        @response.status_of_section(@section1).should eq("Complete")
      end

      it "should be complete with warnings when all mandatory questions are answered but a warning is present" do
        Factory(:answer, question: @q4, response: @response)
        Factory(:answer, question: @q5, response: @response)
        Factory(:answer, question: @q7, response: @response, answer_value: 16)

        @response.section_started?(@section2).should be_true
        @response.status_of_section(@section2).should eq 'Complete with warnings'

      end

      it "should be incomplete if there's any range warnings present and not all mandatory questions are answered" do
        Factory(:answer, question: @q1, response: @response, answer_value: "5")

        @response.section_started?(@section1).should be_true
        @response.status_of_section(@section1).should eq("Incomplete")
      end

      it "should be incomplete if all mandatory questions are answered and garbage is stored" do
        Factory(:answer, question: @q4, response: @response)
        Factory(:answer, question: @q5, response: @response)
        Factory(:answer, question: @q7, answer_value: 'abvcasdfsadf', response: @response)

        @response.section_started?(@section2).should be_true
        @response.status_of_section(@section2).should eq 'Incomplete'
      end

      it "should be incomplete if all mandatory questions are answered and a cross-question validation fails" do
        Factory(:answer, question: @q7, answer_value: 'abvcasdfsadf', response: @response)

        @response.section_started?(@section2).should be_true
        @response.status_of_section(@section2).should eq 'Incomplete'
      end

      it "shows incomplete if a CQV fails even if a range check fails" do
        @section3 = Factory(:section, survey: @survey)
        @q8 = Factory(:question, section: @section3, mandatory: false, question_type: "Date")
        @q9 = Factory(:question, section: @section3, mandatory: false, question_type: "Integer", number_min: 0)

        Factory(:cross_question_validation, rule: 'date_lt', question: @q8, related_question: @q8)
        Factory(:answer, question: @q8, answer_value: Date.today, response: @response)
        Factory(:answer, question: @q9, answer_value: -1, response: @response)

        @response.section_started?(@section3).should be_true
        @response.status_of_section(@section3).should eq 'Incomplete'
      end
    end
  end
end
