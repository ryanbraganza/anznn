Feature: Upload survey responses in a batch file
  In order to quickly provide my data
  As a data provider
  I want to upload a batch file

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have year of registration range configured as "2005" to "2009"
    And I have a survey with name "MySurvey"
    And I have a survey with name "MySurvey2"
    And I have a survey with name "Test Survey" with questions from "survey/survey_questions.csv" and options from "survey/survey_options.csv"

  Scenario: Upload a file
    Given I am on the home page
    When I follow "Batch Uploads"
    And I follow "Upload Batch File"
    Then the "Registration type" select should contain
      | Please select |
      | MySurvey      |
      | MySurvey2     |
      | Test Survey   |
    And the "Year of registration" select should contain
      | Please select |
      | 2005          |
      | 2006          |
      | 2007          |
      | 2008          |
      | 2009          |
    And I should see "Please select the registration type and the file you want to upload"
    When I select "MySurvey" from "Registration type"
    And I select "2007" from "Year of registration"
    And I attach the file "test_data/survey/batch_files/batch_sample.csv" to "File"
    And I press "Upload"
    Then I should be on the list of batch uploads page
    And I should see "Your upload has been received and is now being processed. This may take some time depending on the size of the file."
    And I should see "The status of your uploads can be seen in the table below. Click the 'Refresh Status' button to see an updated status."
    And I should have a batch file stored for survey "MySurvey" with uploader "data.provider@intersect.org.au" and hospital "RPA"

  Scenario: Accepts duplicates
    When I upload batch file "batch_sample.csv" for survey "MySurvey"
    And I upload batch file "batch_sample.csv" for survey "MySurvey"
    Then I should have two batch files stored with name "batch_sample.csv"

  Scenario: Validates that both survey type, year of registration and a file are provided
    Given I am on the list of batch uploads page
    When I follow "Upload Batch File"
    And I press "Upload"
    Then I should see "Registration type can't be blank"
    Then I should see "Year of registration can't be blank"
    And I should see "File can't be blank"
    And I should have no batch files

  Scenario: Administrators don't see the upload button and can't get to upload page
    Given I am logged in as "super@intersect.org.au" and have role "Administrator"
    When I am on the list of batch uploads page
    Then I should not see "Upload Batch File"
    And I should get a security error when I visit the upload batch file page

  Scenario Outline: Data Providers and administrators don't see a last column
    Given I upload batch file "batch_sample.csv" for survey "MySurvey"
    When I am logged in as "<user>@intersect.org.au" and have role "<role>"
    And I am on the list of batch uploads page
    Then the "batch_uploads" table should have 9 columns
  Examples:
    | user          | role          |
    | data.provider | Data Provider |
    | administrator | Administrator |

  Scenario: Supervisors see an extra column
    Given I am logged in as "supervisor@intersect.org.au" and have role "Data Provider Supervisor" and I'm linked to hospital "RPA"
    And I upload batch file as "supervisor@intersect.org.au" "batch_sample.csv" for survey "MySurvey"
    When I am on the list of batch uploads page
    Then the "batch_uploads" table should have 10 columns

  Scenario: Supervisors see an extra column
    Given I am logged in as "supervisor@intersect.org.au" and have role "Data Provider Supervisor" and I'm linked to hospital "RPA"
    And I upload batch file as "supervisor@intersect.org.au" "number_out_of_range.csv" for survey "Test Survey"
    And I sleep for 1
    And I upload batch file as "supervisor@intersect.org.au" "no_errors_or_warnings.csv" for survey "Test Survey"
    When I am on the list of batch uploads page
    Then the "batch_uploads" table should have 10 columns
    And the batch uploads table should look like
      | Registration Type | Status      |
      | Test Survey       | In Progress |
      | Test Survey       | In Progress |
    When the batch files are processed
    And I am on the list of batch uploads page
    And the batch uploads table should look like
      | Registration Type | Filename                  | Status                 |              |
      | Test Survey       | no_errors_or_warnings.csv | Processed Successfully |              |
      | Test Survey       | number_out_of_range.csv   | Needs Review           | Force Submit |

  Scenario: Supervisors can force submit
    Given I am logged in as "data.provider@intersect.org.au"
    And I upload batch file as "data.provider@intersect.org.au" "number_out_of_range.csv" for survey "Test Survey"
    And I am on the list of batch uploads page
    Then the "batch_uploads" table should have 9 columns
    And I should see "batch_uploads" table with
      | Registration Type | Status      |
      | Test Survey       | In Progress |
    When the batch files are processed
    And I am on the list of batch uploads page
    Then I should see "batch_uploads" table with
      | Registration Type | Status       |
      | Test Survey       | Needs Review |

    Given I am logged in as "supervisor@intersect.org.au" and have role "Data Provider Supervisor" and I'm linked to hospital "RPA"
    When I am on the list of batch uploads page
    And the "batch_uploads" table should have 10 columns
    Then the batch uploads table should look like
      | Registration Type | Filename                | Status       |              |
      | Test Survey       | number_out_of_range.csv | Needs Review | Force Submit |
    When I force submit for "number_out_of_range.csv"
    Then I should be on the list of batch uploads page
    And I should see "Your request is now being processed. This may take some time depending on the size of the file."
    And I should see "batch_uploads" table with
      | Registration Type | Filename                | Status       |
      | Test Survey       | number_out_of_range.csv | Needs Review |

    When the batch files are processed
    And I am on the list of batch uploads page
    Then I should see "batch_uploads" table with
      | Registration Type | Status                 |  |
      | Test Survey       | Processed Successfully |  |
