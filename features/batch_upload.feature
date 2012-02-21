Feature: Upload survey responses in a batch file
  In order to quickly provide my data
  As a data provider
  I want to upload a batch file

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"
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
    And I attach the file "features/sample_data/batch_sample.csv" to "File"
    When I press "Upload"
    Then I should see "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
    And I should see "The status of your uploads can be seen in the table below. You will need to refresh the page to see an updated status."
    And I should have a batch file stored for survey "MySurvey" with uploader "data.provider@intersect.org.au"

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
