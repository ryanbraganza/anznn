require 'spec_helper'

describe BatchDetailReportGenerator do

  let(:survey) do
    survey = Factory(:survey)
    s1 = Factory(:section, survey: survey)
    s2 = Factory(:section, survey: survey)
    Factory(:question, section: s1, question_type: Question::TYPE_TEXT, mandatory: true, code: "TextMandatory")
    Factory(:question, section: s1, question_type: Question::TYPE_TEXT, mandatory: false, code: "TextOptional")
    date1 = Factory(:question, section: s1, question_type: Question::TYPE_DATE, mandatory: false, code: "Date1")
    date2 = Factory(:question, section: s1, question_type: Question::TYPE_DATE, mandatory: false, code: "Date2")
    Factory(:question, section: s1, question_type: Question::TYPE_TIME, mandatory: false, code: "Time")
    choice_q = Factory(:question, section: s2, question_type: Question::TYPE_CHOICE, mandatory: false, code: "Choice")
    Factory(:question, section: s2, question_type: Question::TYPE_DECIMAL, mandatory: false, code: "Decimal")
    Factory(:question, section: s2, question_type: Question::TYPE_INTEGER, mandatory: false, code: "Integer", number_min: 5)

    Factory(:question_option, question: choice_q, option_value: "0", label: "No")
    Factory(:question_option, question: choice_q, option_value: "1", label: "Yes")
    Factory(:question_option, question: choice_q, option_value: "99", label: "Dunno")

    Factory(:cross_question_validation, question: date1, related_question: date2, rule: 'date_gt', error_message: 'date prob')
    survey.reload
    survey
  end
  let(:user) { Factory(:user) }
  let(:hospital) { Factory(:hospital) }

  it "should produce a CSV file with correct error and warning details" do
    batch_file = BatchFile.create!(file: Rack::Test::UploadedFile.new('features/sample_data/batch_files/a_range_of_problems.csv', 'text/csv'), survey: survey, user: user, hospital: hospital)
    # TODO: this is an integration test so we're checking report generation by calling batch_file.process - should probably look at refactoring this
    batch_file.process

    csv_file = batch_file.detail_report_path

    rows = CSV.read(csv_file)
    rows.size.should eq(7)
    rows[0].should eq(["BabyCode", "Column Name", "Type", "Value", "Message"])
    rows[1].should eq(['B1', 'Date1', 'Error', '2011-ab-25', 'Answer is invalid (must be a valid date)'])
    rows[2].should eq(['B1', 'Decimal', 'Error', 'a.77', 'Answer is the wrong format (Expected a decimal value)'])
    rows[3].should eq(['B1', 'TextMandatory', 'Error', '', 'This question is mandatory'])
    rows[4].should eq(['B2', 'Integer', 'Warning', '3', 'Answer should be at least 5'])
    rows[5].should eq(['B2', 'Time', 'Error', 'ab:59', 'Answer is invalid (must be a valid time)'])
    rows[6].should eq(['B3', 'Date1', 'Error', '2010-05-29', 'date prob'])

  end
end