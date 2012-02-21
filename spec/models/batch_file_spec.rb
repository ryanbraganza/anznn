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

  describe "Processing the file" do
    describe "Invalid files" do
      it "rejects file without a baby code column" do
        batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/no_baby_code_column.csv', 'text/csv'), survey: Factory(:survey), user: Factory(:user))
        batch_file.process
        batch_file.reload
        batch_file.status.should eq("Failed - invalid file")
      end

      describe "rejects file that can't be parsed as CSV" do
        it "should handle binary files such as xls" do
          batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/not_csv.xls', 'text/csv'), survey: Factory(:survey), user: Factory(:user))
          batch_file.process
          batch_file.reload
          batch_file.status.should eq("Failed - invalid file")
        end

        it "should handle files that are text but have malformed csv" do
          batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/invalid_csv.csv', 'text/csv'), survey: Factory(:survey), user: Factory(:user))
          batch_file.process
          batch_file.reload
          batch_file.status.should eq("Failed - invalid file")
        end
      end
    end
  end
end
