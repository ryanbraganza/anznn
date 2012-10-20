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
      section2 = Factory(:section, survey: survey, section_order: 2)
      section1 = Factory(:section, survey: survey, section_order: 1)
      q_choice = Factory(:question, section: section1, question_order: 1, question_type: Question::TYPE_CHOICE, code: 'ChoiceQ')
      q_date = Factory(:question, section: section1, question_order: 3, question_type: Question::TYPE_DATE, code: 'DateQ')
      q_decimal = Factory(:question, section: section2, question_order: 2, question_type: Question::TYPE_DECIMAL, code: 'DecimalQ')
      q_integer = Factory(:question, section: section2, question_order: 1, question_type: Question::TYPE_INTEGER, code: 'IntegerQ')
      q_text = Factory(:question, section: section1, question_order: 2, question_type: Question::TYPE_TEXT, code: 'TextQ')
      q_time = Factory(:question, section: section1, question_order: 4, question_type: Question::TYPE_TIME, code: 'TimeQ')

      response1 = Factory(:response, hospital: Factory(:hospital, abbrev: 'HRL'), survey: survey, year_of_registration: 2009, baby_code: 'ABC-123')
      Factory(:answer, response: response1, question: q_choice, answer_value: '1')
      Factory(:answer, response: response1, question: q_date, answer_value: '25/02/2001')
      Factory(:answer, response: response1, question: q_decimal, answer_value: '15.5673')
      Factory(:answer, response: response1, question: q_integer, answer_value: '877')
      Factory(:answer, response: response1, question: q_text, answer_value: 'ABc')
      Factory(:answer, response: response1, question: q_time, answer_value: '14:56')
      response1.reload
      response1.save!

      response2 = Factory(:response, hospital: Factory(:hospital, abbrev: 'BBB'), survey: survey, year_of_registration: 2011, baby_code: 'DEF-567')
      Factory(:answer, response: response2, question: q_integer, answer_value: '99')
      Factory(:answer, response: response2, question: q_text, answer_value: 'ABCdefg Ijkl')
      response2.reload
      response2.save!

      Response.should_receive(:for_survey_hospital_and_year_of_registration).with(survey, '', '').and_return([response1, response2])
      csv = CsvGenerator.new(survey.id, '', '').csv
      expected = []
      expected << %w(RegistrationType YearOfRegistration Hospital BabyCODE ChoiceQ TextQ DateQ TimeQ IntegerQ DecimalQ)
      expected << ['Survey One', '2009', 'HRL', 'ABC-123', '1', 'ABc', '2001-02-25', '14:56', '877', '15.5673']
      expected << ['Survey One', '2011', 'BBB', 'DEF-567', '', 'ABCdefg Ijkl', '', '', '99', '']
      CSV.parse(csv).should eq(expected)
    end
  end

end
