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
    let(:survey) { Factory(:survey) }
    let(:user) { Factory(:user) }

    describe "Invalid files" do
      it "should reject file without a baby code column" do
        batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/no_baby_code_column.csv', 'text/csv'), survey: survey, user: user)
        batch_file.process
        batch_file.reload
        batch_file.status.should eq("Failed - invalid file")
      end

      it "should handle binary files such as xls" do
        batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/not_csv.xls', 'text/csv'), survey: survey, user: user)
        batch_file.process
        batch_file.reload
        batch_file.status.should eq("Failed - invalid file")
      end

      it "should reject files that are text but have malformed csv" do
        batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/invalid_csv.csv', 'text/csv'), survey: survey, user: user)
        batch_file.process
        batch_file.reload
        batch_file.status.should eq("Failed - invalid file")
      end
    end

    describe "Valid file with no errors or warnings" do
      it "Should create the survey responses and answers" do
        batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/no_errors_or_warnings.csv', 'text/csv'), survey: survey, user: user)
        batch_file.process
        batch_file.reload
        batch_file.status.should eq("Processed successfully")
        Response.count.should == 3
        r1 = Response.find_by_baby_code!("B1")
        r2 = Response.find_by_baby_code!("B2")
        r3 = Response.find_by_baby_code!("B3")

        [r1, r2, r3].each do |r|
          r.survey.should eq(survey)
          r.user.should eq(user)
        end
      end
    end

    describe "Valid file with missing baby codes" do
      it "Should set the file status to failed if any baby codes are missing, and not save any responses" do
        batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/missing_baby_code.csv', 'text/csv'), survey: survey, user: user)
        batch_file.process
        batch_file.reload
        batch_file.status.should eq("Failed")
        Response.count.should == 0
        Answer.count.should == 0
      end

    end
  end
end
