Feature: Upload survey responses in a batch file
  In order to quickly provide my data
  As a data provider
  I want to upload a batch file

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have a survey with name "MySurvey"
    And I have a survey with name "MySurvey2"

  Scenario: Upload a file
    Given I am on the home page
    When I follow "Upload Batch File"
    Then the "Survey" select should contain
      | Please select |
      | MySurvey      |
      | MySurvey2     |
    Then I should see "Please select the survey type and the file you want to upload"
    When I select "MySurvey" from "Survey"
    And I attach the file "features/sample_data/batch_files/batch_sample.csv" to "File"
    When I press "Upload"
    Then I should see "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
    And I should see "The status of your uploads can be seen in the table below. You will need to refresh the page to see an updated status."
    And I should have a batch file stored for survey "MySurvey" with uploader "data.provider@intersect.org.au" and hospital "RPA"

  Scenario: Accepts duplicates
    Given I upload batch file "batch_sample.csv" for survey "MySurvey"
    And I upload batch file "batch_sample.csv" for survey "MySurvey"
    Then I should have two batch files stored

  Scenario: Validates that both survey type and a file are provided
    Given I am on the home page
    When I follow "Upload Batch File"
    When I press "Upload"
    Then I should see "Survey can't be blank"
    And I should see "File can't be blank"
    And I should have no batch files

  Scenario: View a list of batch uploads
    Given I have a user "fred@intersect.org.au"
    Given "fred@intersect.org.au" has name "Fred" "Smith"
    Given "data.provider@intersect.org.au" has name "Data" "Provider"
    Given I have batch uploads
      | survey    | created_by                     | created_at       | status      | message   |
      | MySurvey  | data.provider@intersect.org.au | 2012-01-03 13:56 | In Progress | Message 1 |
      | MySurvey2 | data.provider@intersect.org.au | 2012-01-04 13:56 | In Progress | Message 2 |
      | MySurvey  | fred@intersect.org.au          | 2012-01-03 08:00 | Succeeded   | Message 3 |
      | MySurvey2 | fred@intersect.org.au          | 2012-01-03 11:23 | Failed      | Message 4 |
    When I am on the home page
    Then I should see "batch_uploads" table with
      | Survey Type | Created By    | Date Uploaded          | Status      | Details   |
      | MySurvey2   | Data Provider | January 04, 2012 13:56 | In Progress | Message 2 |
      | MySurvey    | Data Provider | January 03, 2012 13:56 | In Progress | Message 1 |
      | MySurvey2   | Fred Smith    | January 03, 2012 11:23 | Failed      | Message 4 |
      | MySurvey    | Fred Smith    | January 03, 2012 08:00 | Succeeded   | Message 3 |
