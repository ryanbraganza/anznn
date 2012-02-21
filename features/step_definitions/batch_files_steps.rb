Then /^I should have a batch file stored for survey "([^"]*)" with uploader "([^"]*)"$/ do |survey_name, email|
  check_batch_file(survey_name, email)
end

Given /^I upload batch file "([^"]*)" for survey "([^"]*)"$/ do |filename, survey_name|
  visit root_path
  click_link "Upload Batch File"
  select survey_name, from: "Survey"
  attach_file("File", File.expand_path("features/sample_data/#{filename}"))
  click_button "Upload"
  page.should have_content "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
  page.should have_content "The status of your uploads can be seen in the table below. You will need to refresh the page to see an updated status."
  check_batch_file(survey_name, User.last.email)
end

Then /^I should have two batch files stored$/ do
  BatchFile.count.should eq(2)
  first_path = BatchFile.first.file.path
  last_path = BatchFile.last.file.path
  first_path.should_not eq(last_path)
end

Then /^I should have no batch files$/ do
  BatchFile.count.should eq(2)
end

def check_batch_file(survey_name, email)
  file = BatchFile.last
  file.survey.should eq(Survey.find_by_name!(survey_name))
  file.user.should eq(User.find_by_email!(email))
  # since the test env is configured to store files in tmp, we look for them there
  expected_path = Rails.root.join("tmp/#{file.id}.csv").to_s
  file.file.path.should eq(expected_path)

end