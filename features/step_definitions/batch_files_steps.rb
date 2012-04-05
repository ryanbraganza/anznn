Then /^I should have a batch file stored for survey "([^"]*)" with uploader "([^"]*)" and hospital "([^"]*)"$/ do |survey_name, email, hospital_name|
  check_batch_file(survey_name, email, hospital_name)
end

Then /^the batch uploads table should look like$/ do |expected_table|
  actual = find("table#batch_uploads").all('tr').map do |row|
    elems = row.all('th, td')
    elems.map.with_index(1) do |cell, i|
      if i == elems.length and cell.tag_name == 'td'
        begin
          cell.find('input[type=submit]').value
        rescue Capybara::ElementNotFound
          ''
        end
      else
        cell.text.strip
      end
    end
  end
  chatty_diff_table!(expected_table, actual)
end

When /^I force submit for "(.*)"$/ do |filename|
  # should be on homepage first
  current_url.should eq batch_files_url
  bf = BatchFile.find_by_file_file_name! filename

  click_button "force_submit_#{bf.id}"
end

Given /^I upload batch file( as "(.*)")? "([^"]*)" for survey "([^"]*)"$/ do |as_user, email, filename, survey_name|
  visit batch_files_path
  click_link "Upload Batch File"
  select survey_name, from: "Survey"
  select "2009", from: "Year of registration"
  attach_file("File", File.expand_path("test_data/survey/batch_files/#{filename}"))
  click_button "Upload"
  page.should have_content "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
  page.should have_content "The status of your uploads can be seen in the table below. Click the 'Refresh Status' button to see an updated status."
  if as_user
    user = User.find_by_email!(email)
  else
    user = User.first
  end
  check_batch_file(survey_name, user.email, user.hospital.name)
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
    summary = attrs.delete("summary report") == "true"
    detail = attrs.delete("detail report") == "true"

    bf = Factory(:batch_file, attrs.merge(survey: survey, user: uploader, hospital: hospital))

    #create fake reports so we can test downloading them
    if summary
      file_path = File.join(APP_CONFIG['batch_reports_path'], "#{bf.id}-summary.pdf")
      Prawn::Document.generate file_path do
        text "Fake PDF"
      end
      bf.summary_report_path = file_path
    end

    if detail
      file_path = File.join(APP_CONFIG['batch_reports_path'], "#{bf.id}-details.csv")
      CSV.open(file_path, "wb") do |csv|
        csv.add_row ['BabyCode', 'Column Name', 'Type', 'Value', 'Message']
        csv.add_row ['1', 'MoAge', 'Error', '6', 'A bad value']
      end
      bf.detail_report_path = file_path
    end

    bf.save!
  end
end

When /^the system processes the latest upload$/ do
  bf = BatchFile.last
  bf.process
end

When /^the batch files are processed$/ do
  Delayed::Job.all.each do |j|
    j.invoke_job
    j.destroy
  end
end

def check_batch_file(survey_name, email, hospital_name)
  file = BatchFile.last
  file.survey.should eq(Survey.find_by_name!(survey_name))
  file.user.should eq(User.find_by_email!(email))
  file.hospital.should eq(Hospital.find_by_name!(hospital_name))
  # since the test env is configured to store files in tmp, we look for them there
  ext = File.extname(file.file_file_name)
  expected_path = Rails.root.join("tmp/#{file.id}#{ext}").to_s
  file.file.path.should eq(expected_path)
end
