require 'spec_helper'

describe Response do
  describe "Associations" do
    it { should belong_to :survey }
    it { should belong_to :user }
    it { should belong_to :hospital }
    it { should have_many :answers }
    it { should belong_to :batch_file }
  end

  describe "Validations" do
    it { should validate_presence_of :baby_code }
    it { should validate_presence_of :user }
    it { should validate_presence_of :survey_id }
    it { should validate_presence_of :year_of_registration }

    it "should validate that submitted_status is one of the allowed types" do
      [Response::STATUS_SUBMITTED, Response::STATUS_UNSUBMITTED].each do |value|
        should allow_value(value).for(:submitted_status)
      end
      Factory.build(:response, submitted_status: nil).should_not be_valid
      Factory.build(:response, submitted_status: "Blah").should_not be_valid
    end

    it "should validate that baby code is unique within survey" do
      first = Factory(:response, baby_code: "abcd")
      second = Factory.build(:response, survey: first.survey, baby_code: first.baby_code)
      second.should_not be_valid
      second.errors.full_messages.should eq(["Baby code abcd has already been used."])
      diff_survey = Factory.build(:response, survey: Factory(:survey), baby_code: first.baby_code)
      diff_survey.should be_valid
    end

    it "should strip leading/trailing spaces from baby codes before validating" do
      first = Factory(:response, baby_code: " abcd ")
      first.baby_code.should eq("abcd")

      second = Factory.build(:response, survey: first.survey, baby_code: " abcd")
      second.should_not be_valid
      second.errors.full_messages.should eq(["Baby code abcd has already been used."])
    end
  end

  describe "Scopes" do
    it "for survey scope should return responses for the given survey" do
      survey_a = Factory(:survey)
      survey_b = Factory(:survey)
      r1 = Factory(:response, survey: survey_a)
      r2 = Factory(:response, survey: survey_b)
      r3 = Factory(:response, survey: survey_a)
      matches = Response.for_survey(survey_a).collect(&:id).sort
      matches.should eq([r1.id, r3.id])
    end

    it "unsubmitted scope should return responses that are unsubmitted" do
      r1 = Factory(:response, submitted_status: Response::STATUS_UNSUBMITTED)
      r2 = Factory(:response, submitted_status: Response::STATUS_SUBMITTED)
      r3 = Factory(:response, submitted_status: Response::STATUS_UNSUBMITTED)
      matches = Response.unsubmitted.collect(&:id).sort
      matches.should eq([r1.id, r3.id])
    end
  end

  describe "Getting submitted responses by survey, hospital and year of reg" do
    before(:each) do
      @survey_a = Factory(:survey)
      @survey_b = Factory(:survey)
      @hospital_a = Factory(:hospital)
      @hospital_b = Factory(:hospital)
      @r1 = Factory(:response, survey: @survey_a, hospital: @hospital_a, year_of_registration: 2001, submitted_status: Response::STATUS_SUBMITTED).id
      @r2 = Factory(:response, survey: @survey_a, hospital: @hospital_a, year_of_registration: 2001, submitted_status: Response::STATUS_SUBMITTED).id
      @r3 = Factory(:response, survey: @survey_a, hospital: @hospital_a, year_of_registration: 2002, submitted_status: Response::STATUS_SUBMITTED).id
      @r4 = Factory(:response, survey: @survey_a, hospital: @hospital_b, year_of_registration: 2001, submitted_status: Response::STATUS_SUBMITTED).id
      @r5 = Factory(:response, survey: @survey_a, hospital: @hospital_b, year_of_registration: 2002, submitted_status: Response::STATUS_SUBMITTED).id
      @r6 = Factory(:response, survey: @survey_a, hospital: @hospital_b, year_of_registration: 2003, submitted_status: Response::STATUS_SUBMITTED).id
      @r7 = Factory(:response, survey: @survey_b, hospital: @hospital_a, year_of_registration: 2001, submitted_status: Response::STATUS_SUBMITTED).id
      @r8 = Factory(:response, survey: @survey_a, hospital: @hospital_a, year_of_registration: 2001, submitted_status: Response::STATUS_UNSUBMITTED).id
    end

    it "should return all submitted responses for survey when hospital and year of reg not provided" do
      Response.for_survey_hospital_and_year_of_registration(@survey_a, "", "").collect(&:id).should eq([@r1, @r2, @r3, @r4, @r5, @r6])
    end

    it "should filter by hospital when provided" do
      Response.for_survey_hospital_and_year_of_registration(@survey_a, @hospital_a.id, "").collect(&:id).should eq([@r1, @r2, @r3])
    end

    it "should filter by year of reg when provided" do
      Response.for_survey_hospital_and_year_of_registration(@survey_a, "", "2001").collect(&:id).should eq([@r1, @r2, @r4])
    end

    it "should filter by hospital and year of reg when both provided" do
      Response.for_survey_hospital_and_year_of_registration(@survey_a, @hospital_a.id, "2001").collect(&:id).should eq([@r1, @r2])
    end
  end

  describe "Getting the full set of possible years of registration" do
    it "returns unique values in ascending order" do
      Factory(:response, year_of_registration: 2009)
      Factory(:response, year_of_registration: 2007)
      Factory(:response, year_of_registration: 2009)
      Factory(:response, year_of_registration: 2011)
      Response.existing_years_of_registration.should eq([2007, 2009, 2011])
    end
  end

  describe "submit" do
    let(:response) {Factory(:response)}
    it "should set the status of the response when complete" do
      response.stub(:status) { Response::COMPLETE }
      response.submitted_status.should eq Response::STATUS_UNSUBMITTED

      response.submit!

      response.submitted_status.should eq Response::STATUS_SUBMITTED
      response.reload

      response.submitted_status.should eq Response::STATUS_SUBMITTED
    end
    it "should set the status of the response when complete with warnings" do
      response.stub(:status) { Response::COMPLETE_WITH_WARNINGS }
      response.submitted_status.should eq Response::STATUS_UNSUBMITTED

      response.submit!

      response.submitted_status.should eq Response::STATUS_SUBMITTED
      response.reload

      response.submitted_status.should eq Response::STATUS_SUBMITTED
    end
    it "can't submit a response incomplete" do
      response.stub(:status) { Response::INCOMPLETE }

      expect { response.submit! }.should raise_error
    end
  end

  describe "submit_warning" do
    let(:response) {Factory(:response)}
    it "dies on complete" do
      response.stub(:status) { Response::COMPLETE }
      response.submit_warning.should be_nil
    end
    it "shows a warning for incomplete" do
      response.stub(:status) { Response::INCOMPLETE }
      response.submit_warning.should eq "This survey is incomplete and can't be submitted."
    end
    it "shows a warning for complete with warnings" do
      response.stub(:status) { Response::COMPLETE_WITH_WARNINGS }
      response.submit_warning.should eq "This survey has warnings. Double check them. If you believe them to be correct, contact a supervisor."
    end
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
      it "incomplete when nothing done yet" do
        @response.status.should eq "Incomplete"
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

      it "should be incomplete if no answers have been saved yet" do
        @response.section_started?(@section1).should be_false
        @response.status_of_section(@section1).should eq("Incomplete")
        @response.section_started?(@section2).should be_false
        @response.status_of_section(@section2).should eq("Incomplete")
      end

      it "should be incomplete if at least one question is answered but not all mandatory questions are answered" do
        Factory(:answer, question: @q1, response: @response)

        @response.section_started?(@section1).should be_true
        @response.status_of_section(@section1).should eq("Incomplete")
        @response.section_started?(@section2).should be_false
        @response.status_of_section(@section2).should eq("Incomplete")
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

        Factory(:cross_question_validation, rule: 'comparison', operator: '<', question: @q8, related_question: @q8)
        Factory(:answer, question: @q8, answer_value: Date.today, response: @response)
        Factory(:answer, question: @q9, answer_value: -1, response: @response)

        @response.section_started?(@section3).should be_true
        @response.status_of_section(@section3).should eq 'Incomplete'
      end
    end
  end

  describe "Finding out if a response has warnings or fatal warnings" do
    before(:each) do
      @survey = Factory(:survey)
      @section = Factory(:section, survey: @survey)
      @question1 = Factory(:question, mandatory: true, section: @section, code: "A", question_type: Question::TYPE_INTEGER, number_min: 5)
      @question2 = Factory(:question, mandatory: false, section: @section, code: "B")
    end

    it "both warnings and fatal warnings are true if mandatory questions are missing" do
      response = Factory(:response, survey: @survey)
      response.fatal_warnings?.should be_true
      response.warnings?.should be_true
      response.build_answers_from_hash({"B" => "B answer"})
      response.save!
      response.reload
      response.fatal_warnings?.should be_true
      response.warnings?.should be_true
    end

    it "both warnings and fatal warnings are false if mandatory questions are all answered" do
      response = Factory(:response, survey: @survey)
      response.build_answers_from_hash({"A" => "10"})
      response.save!
      response.reload
      response.fatal_warnings?.should be_false
      response.warnings?.should be_false
    end

    it "has fatal warnings and has warnings are both true if at least one answer has a fatal warning" do
      response = Factory(:response, survey: @survey)
      response.build_answers_from_hash({"A" => "A answer", "B" => "B answer"}) #A answer is invalid
      response.fatal_warnings?.should be_true
      response.warnings?.should be_true
    end

    it "has fatal warnings is false but has warnings is true if at least one answer has a warning but none have fatal warnings" do
      response = Factory(:response, survey: @survey)
      response.build_answers_from_hash({"A" => "2", "B" => "B answer"}) #A is out of range
      response.fatal_warnings?.should be_false
      response.warnings?.should be_true
    end

    it "has fatal warnings and has warnings are both false if no answers have warnings or fatal warnings" do
      response = Factory(:response, survey: @survey)
      response.build_answers_from_hash({"A" => "7", "B" => "B answer"}) #A is out of range
      response.fatal_warnings?.should be_false
      response.warnings?.should be_false
    end
  end
end
