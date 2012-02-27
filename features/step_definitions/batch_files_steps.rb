Then /^I should have a batch file stored for survey "([^"]*)" with uploader "([^"]*)" and hospital "([^"]*)"$/ do |survey_name, email, hospital_name|
  check_batch_file(survey_name, email, hospital_name)
end

Given /^I upload batch file "([^"]*)" for survey "([^"]*)"$/ do |filename, survey_name|
  visit root_path
  click_link "Upload Batch File"
  select survey_name, from: "Survey"
  attach_file("File", File.expand_path("features/sample_data/batch_files/#{filename}"))
  click_button "Upload"
  page.should have_content "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
  page.should have_content "The status of your uploads can be seen in the table below. You will need to refresh the page to see an updated status."
  check_batch_file(survey_name, User.first.email, User.first.hospital.name)
end

Then /^I should have two batch files stored with name "([^"]*)"$/ do |name|
  files = BatchFile.find_all_by_file_file_name(name)
  files.count.should eq(2)
  files[0].file.path.should_not eq(files[1].file.path)
end

Then /^I should have no batch files$/ do
  BatchFile.count.should eq(0)
end

Given /^I have batch uploads$/ do |table|
  table.hashes.each do |attrs|
    survey = Survey.find_by_name!(attrs.delete("survey"))
    uploader = User.find_by_email!(attrs.delete("created_by"))
    hospital_name = attrs.delete("hospital")
    hospital = Hospital.find_by_name(hospital_name)
    hospital ||= Factory(:hospital, name: hospital_name)
    reports = attrs.delete("report") == "true"

    bf = Factory(:batch_file, attrs.merge(survey: survey, user: uploader, hospital: hospital))

    #create fake reports so we can test downloading them
    if reports
      file_path = File.join(APP_CONFIG['summary_reports_path'], "#{bf.id}-summary.pdf")
      Prawn::Document.generate file_path do
        text "Fake PDF"
      end
    end
    bf.summary_report_path = file_path
    bf.save!
  end
end

def check_batch_file(survey_name, email, hospital_name)
  file = BatchFile.last
  file.survey.should eq(Survey.find_by_name!(survey_name))
  file.user.should eq(User.find_by_email!(email))
  file.hospital.should eq(Hospital.find_by_name!(hospital_name))
  # since the test env is configured to store files in tmp, we look for them there
  expected_path = Rails.root.join("tmp/#{file.id}.csv").to_s
  file.file.path.should eq(expected_path)
end
