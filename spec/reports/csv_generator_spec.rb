require 'spec_helper'

describe CsvGenerator do
  let(:survey) { Factory(:survey, name: "Survey One") }
  let(:hospital) { Factory(:hospital, name: "Royal North Shore", abbrev: "RNS") }

  describe "Generating the filename" do

    it "includes only survey name when no hospital or year of registration" do
      CsvGenerator.new(survey.id, "", "").csv_filename.should eq("survey_one.csv")
    end

    it "includes survey name and hospital when hospital set" do
      CsvGenerator.new(survey.id, hospital.id, "").csv_filename.should eq("survey_one_rns.csv")

    end

    it "includes survey name and year of registration when year of registration set" do
      CsvGenerator.new(survey.id, "", "2009").csv_filename.should eq("survey_one_2009.csv")

    end

    it "includes survey name, hospital and year of registration when all are set" do
      CsvGenerator.new(survey.id, hospital.id, "2009").csv_filename.should eq("survey_one_rns_2009.csv")

    end

    it "makes the survey name safe for use in a filename" do
      survey = Factory(:survey, name: "SurVey %/\#.()A,|")
      CsvGenerator.new(survey.id, "", "").csv_filename.should eq("survey_a.csv")
    end

    it "makes the hospital abbreviation safe for use in a filename" do
      hospital = Factory(:hospital, abbrev: "HosPITAL %/\#.()A,|")
      CsvGenerator.new(survey.id, hospital.id, "").csv_filename.should eq("survey_one_hospital_a.csv")
    end
  end

  describe "Checking for emptiness" do
    it "returns true if there's no matching records" do
      Response.should_receive(:for_survey_hospital_and_year_of_registration).with(survey, hospital.id, "2009").and_return([])
      CsvGenerator.new(survey.id, hospital.id, "2009").should be_empty
    end

    it "returns false if there's matching records" do
      Response.should_receive(:for_survey_hospital_and_year_of_registration).and_return(["something"])
      CsvGenerator.new(survey.id, "", "").should_not be_empty
    end
  end

  describe "Generating the CSV" do
    it "includes the correct details" do
      response1 = Factory(:response, hospital: Factory(:hospital, abbrev: "HRL"), survey: survey, year_of_registration: 2009, baby_code: "ABC-123")
      response2 = Factory(:response, hospital: Factory(:hospital, abbrev: "BBB"), survey: survey, year_of_registration: 2011, baby_code: "DEF-567")
      Response.should_receive(:for_survey_hospital_and_year_of_registration).with(survey, "", "").and_return([response1, response2])
      csv = CsvGenerator.new(survey.id, "", "").csv
      expected = []
      expected << ["Survey", "YearOfRegistration", "Hospital", "BabyCode"]
      expected << ["Survey One", "2009", "HRL", "ABC-123"]
      expected << ["Survey One", "2011", "BBB", "DEF-567"]
      CSV.parse(csv).should eq(expected)
    end
  end

end