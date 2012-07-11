require 'spec_helper'

describe SupplementaryFile do
  describe "Associations" do
    it { should belong_to(:batch_file) }
  end

  describe "Validations" do
    it { should validate_presence_of(:multi_name) }
  end
  
  describe "Validate file" do
    it "should reject binary files such as xls" do
      supplementary_file = create_supplementary_file('not_csv.xls', 'my multi')
      supplementary_file.pre_process.should be_false
      supplementary_file.message.should eq("The supplementary file you uploaded for 'my multi' was not a valid CSV file.")
    end

    it "should reject files that are text but have malformed csv" do
      supplementary_file = create_supplementary_file('invalid_csv.csv', 'my multi')
      supplementary_file.pre_process.should be_false
      supplementary_file.message.should eq("The supplementary file you uploaded for 'my multi' was not a valid CSV file.")
    end

    it "should reject file without a baby code column" do
      supplementary_file = create_supplementary_file('no_baby_code_column.csv', 'my multi')
      supplementary_file.pre_process.should be_false
      supplementary_file.message.should eq("The supplementary file you uploaded for 'my multi' did not contain a BabyCode column.")
    end

    it "should reject files that are empty" do
      supplementary_file = create_supplementary_file('empty.csv', 'my multi')
      supplementary_file.pre_process.should be_false
      supplementary_file.message.should eq("The supplementary file you uploaded for 'my multi' did not contain any data.")
    end

    it "should reject files that have a header row only" do
      supplementary_file = create_supplementary_file('headers_only.csv', 'my multi')
      supplementary_file.pre_process.should be_false
      supplementary_file.message.should eq("The supplementary file you uploaded for 'my multi' did not contain any data.")
    end
  end

  describe "Denormalise file" do
    it "should take the rows from the file and stich them together as denormalised answers" do
      # this is a bit hard to express, so commenting for clarity.
      # what we're doing is taking a normalised set of answers and rearranging them to be de-normalised to suit the structure we have
      # e.g. a CSV would contain
      # | BabyCode | SurgeryDate | SurgeryName  |
      # | B1       | 2012-12-1   | blah1        |
      # | B1       | 2012-12-2   | blah2        |
      # | B2       | 2012-12-1   | blah1        |
      # | B2       | 2012-12-2   | blah2        |
      # | B2       | 2012-12-3   | blah3        |
      # and we want to turn that into something like this
      # | BabyCode | SurgeryDate1 | SurgeryName1  | SurgeryDate2 | SurgeryName2  | SurgeryDate3 | SurgeryName3 |
      # | B1       | 2012-12-1    | blah1         |2012-12-2     | blah2         |              |              |
      # | B2       | 2012-12-1    | blah1         |2012-12-2     | blah2         |2012-12-3     | blah3        |

      file = Rack::Test::UploadedFile.new('test_data/survey/batch_files/batch_sample_multi1.csv', 'text/csv')
      supp_file = Factory(:supplementary_file, multi_name: 'xyz', file: file)
      supp_file.pre_process.should be_true

      denormalised = supp_file.as_denormalised_hash
      #File contents:
      #BabyCode,Date,Time
      #B1,2012-12-01,11:45
      #B1,2011-11-01,
      #B2,2011-08-30,01:05
      #B2,2010-03-04,13:23
      #B2,,11:53
      denormalised.size.should eq(2)
      baby1 = denormalised['B1']
      baby1.should eq({'Date1' => '2012-12-01', 'Date2' => '2011-11-01', 'Time1' => '11:45'})
      baby2 = denormalised['B2']
      baby2.should eq({'Date1' => '2011-08-30', 'Date2' => '2010-03-04', 'Time1' => '01:05', 'Time2' => '13:23', 'Time3' => '11:53'})
    end
  end
  
  def create_supplementary_file(filename, multi_name)
    file = Rack::Test::UploadedFile.new('test_data/survey/batch_files/' + filename, 'text/csv')
    Factory(:supplementary_file, multi_name: multi_name, file: file)
  end
end
