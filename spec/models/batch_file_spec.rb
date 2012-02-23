require 'spec_helper'

describe BatchFile do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:survey) }
  end

  describe "Validations" do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:survey_id) }
  end

  describe "New object should have status set to 'In Progress'" do
    it "Should set the status on a new object" do
      Factory(:batch_file).status.should eq("In Progress")
    end

    it "Shouldn't update status if already set" do
      Factory(:batch_file, status: "Mine").status.should eq("Mine")
    end
  end

  describe "File processing" do
    let(:survey) do
      survey = Factory(:survey)
      s1 = Factory(:section, survey: survey)
      s2 = Factory(:section, survey: survey)
      Factory(:question, section: s1, question_type: Question::TYPE_TEXT, mandatory: true, code: "TextMandatory")
      Factory(:question, section: s1, question_type: Question::TYPE_TEXT, mandatory: false, code: "TextOptional")
      Factory(:question, section: s1, question_type: Question::TYPE_DATE, mandatory: false, code: "Date")
      Factory(:question, section: s1, question_type: Question::TYPE_TIME, mandatory: false, code: "Time")
      choice_q = Factory(:question, section: s2, question_type: Question::TYPE_CHOICE, mandatory: false, code: "Choice")
      Factory(:question, section: s2, question_type: Question::TYPE_DECIMAL, mandatory: false, code: "Decimal")
      Factory(:question, section: s2, question_type: Question::TYPE_INTEGER, mandatory: false, code: "Integer")

      Factory(:question_option, question: choice_q, option_value: "0", label: "No")
      Factory(:question_option, question: choice_q, option_value: "1", label: "Yes")
      Factory(:question_option, question: choice_q, option_value: "99", label: "Dunno")
      survey
    end
    let(:user) { Factory(:user) }

    describe "Invalid files" do
      it "should reject file without a baby code column" do
        batch_file = process_batch_file('no_baby_code_column.csv', survey, user)
        batch_file.status.should eq("Failed - invalid file")
      end

      it "should handle binary files such as xls" do
        batch_file = process_batch_file('not_csv.xls', survey, user)
        batch_file.status.should eq("Failed - invalid file")
      end

      it "should reject files that are text but have malformed csv" do
        batch_file = process_batch_file('invalid_csv.csv', survey, user)
        batch_file.status.should eq("Failed - invalid file")
      end
    end

    describe "Valid file with no errors or warnings" do
      it "Should create the survey responses and answers" do
        batch_file = process_batch_file('no_errors_or_warnings.csv', survey, user)
        batch_file.status.should eq("Processed successfully")
        Response.count.should == 3
        Answer.count.should eq(20) #3x7 questions, one not answered
        r1 = Response.find_by_baby_code!("B1")
        r2 = Response.find_by_baby_code!("B2")
        r3 = Response.find_by_baby_code!("B3")

        [r1, r2, r3].each do |r|
          r.survey.should eq(survey)
          r.user.should eq(user)
        end

        answer_hash = r1.answers.reduce({}) { |hash, answer| hash[answer.question.code] = answer; hash }
        answer_hash["TextMandatory"].text_answer.should == "B1Val1"
        answer_hash["TextOptional"].should be_nil #not answered
        answer_hash["Date"].date_answer.should == Date.parse("2011-12-25")
        answer_hash["Time"].time_answer.should == Time.utc(2000, 1, 1, 14, 30)
        answer_hash["Choice"].choice_answer.should == "0"
        answer_hash["Decimal"].decimal_answer.should == 56.77
        answer_hash["Integer"].integer_answer.should == 10
        Answer.all.each { |a| a.has_warning?.should be_false }
      end
    end

    describe "Valid file with missing baby codes" do
      it "Should set the file status to failed if any baby codes are missing, and not save any responses" do
        batch_file = process_batch_file('missing_baby_code.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end
    end

    describe "Valid file with validation errors" do
      it "should reject records with missing mandatory fields" do
        batch_file = process_batch_file('missing_mandatory_fields.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

      it "should reject records with missing mandatory fields - where the column is missing entirely" do
        batch_file = process_batch_file('missing_mandatory_column.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

      it "should reject records with choice answers that are not one of the allowed values for the question" do
        batch_file = process_batch_file('incorrect_choice_answer_value.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

      it "should reject records with integer answers that are badly formed" do
        batch_file = process_batch_file('bad_integer.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

      it "should reject records with decimal answers that are badly formed" do
        batch_file = process_batch_file('bad_decimal.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

      it "should reject records with time answers that are badly formed" do
        batch_file = process_batch_file('bad_time.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

      it "should reject records with date answers that are badly formed" do
        batch_file = process_batch_file('bad_date.csv', survey, user)
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end
    end

    #TODO: files with extra columns
    #Choice value isn't one of the allowed values
  end
end

def process_batch_file(file_name, survey, user)
  batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/' + file_name, 'text/csv'), survey: survey, user: user)
  batch_file.process
  batch_file.reload
  batch_file
end