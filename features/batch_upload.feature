Feature: Upload survey responses in a batch file
  In order to quickly provide my data
  As a data provider
  I want to upload a batch file

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have a survey with name "MySurvey"
    And I have a survey with name "MySurvey2"
    And I have a survey with name "Test Survey" with questions from "survey/survey_questions.csv" and options from "survey/survey_options.csv"

  Scenario: Upload a file
    Given I am on the home page
    When I follow "Upload Batch File"
    Then the "Survey" select should contain
      | Please select |
      | MySurvey      |
      | MySurvey2     |
      | Test Survey   |
    And I should see "Please select the survey type and the file you want to upload"
    When I select "MySurvey" from "Survey"
    And I attach the file "test_data/survey/batch_files/batch_sample.csv" to "File"
    And I press "Upload"
    Then I should see "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
    And I should see "The status of your uploads can be seen in the table below. You will need to refresh the page to see an updated status."
    And I should have a batch file stored for survey "MySurvey" with uploader "data.provider@intersect.org.au" and hospital "RPA"

  Scenario: Accepts duplicates
    When I upload batch file "batch_sample.csv" for survey "MySurvey"
    And I upload batch file "batch_sample.csv" for survey "MySurvey"
    Then I should have two batch files stored with name "batch_sample.csv"

  Scenario: Validates that both survey type and a file are provided
    Given I am on the home page
    When I follow "Upload Batch File"
    And I press "Upload"
    Then I should see "Survey can't be blank"
    And I should see "File can't be blank"
    And I should have no batch files

  Scenario: Administrators don't see the upload button and can't get to upload page
    Given I am logged in as "super@intersect.org.au" and have role "Administrator"
    When I am on the home page
    Then I should not see "Upload Batch File"
    When I am on the upload batch file page
    Then I should be on the home page
    And I should see "You are not authorized to access this page."

  Scenario Outline: Data Providers and administrators don't see a last column
    Given I upload batch file "batch_sample.csv" for survey "MySurvey"
    When I am logged in as "<user>@intersect.org.au" and have role "<role>"
    And I am on the home page
    Then the "batch_uploads" table should have 8 columns
  Examples:
    | user            | role          |
    | data.provider   | Data Provider |
    | administrator   | Administrator |

  Scenario: Supervisors see a sixth column
    Given I am logged in as "data.provider@intersect.org.au"
    And I am on the home page
    And I follow "Upload Batch File"
    And I select "Test Survey" from "Survey"
    And I attach the file "test_data/survey/batch_files/number_out_of_range.csv" to "File"
    And I press "Upload"
    Then I should be on the home page
    And the "batch_uploads" table should have 8 columns
    And I should see "batch_uploads" table with
      | Survey Type | Status      |
      | Test Survey | In Progress |
    When the batch files are processed
    And I am on the home page
    Then I should see "batch_uploads" table with
      | Survey Type | Status       |
      | Test Survey | Needs Review |

    Given I am logged in as "supervisor@intersect.org.au" and have role "Data Provider Supervisor" and I'm linked to hospital "RPA"
    When I am on the home page
    And the "batch_uploads" table should have 9 columns
# TODO test force submit button
    Then I should see "batch_uploads" table with
      | Survey Type | Filename                | Status       |
      | Test Survey | number_out_of_range.csv | Needs Review |
    When I force submit for "number_out_of_range.csv"
    Then I should be on the home page
    And I should see "Your request is now being processed. This may take some time depending on the size of the file."
    And I should see "batch_uploads" table with
      | Survey Type | Filename                | Status       |
      | Test Survey | number_out_of_range.csv | Needs Review |

    When the batch files are processed
    And I am on the home page
    Then I should see "batch_uploads" table with
      | Survey Type | Status                 |
      | Test Survey | Processed Successfully |
