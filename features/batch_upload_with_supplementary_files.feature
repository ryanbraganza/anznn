@javascript
Feature: Upload survey responses in a batch file
  In order to quickly provide my data
  As a data provider
  I want to upload a batch file and include supplementary files for questions that allow multiple answers

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have year of registration range configured as "2005" to "2009"
    And I have a survey with name "MySurvey"
    And I have a survey with name "MySurvey2"
    And I have a survey with name "Test Survey" with questions from "survey/survey_questions_with_multi.csv" and options from "survey/survey_options.csv"
    And I am on the home page
    And I follow "Batch Uploads"
    And I follow "Upload Batch File"

  Scenario: When selecting a survey with "multi" questions, additional file select boxes are shown
    When I select "Test Survey" from "Registration type"
    Then I should see "Supplementary files"
    And I should see "If you wish, you can supply the following data as separate tables"
    And I should see 3 file selects
    And I should see file select "Multi1"
    And I should see file select "Multi2"

  Scenario: When selecting a survey without "multi" questions, additional file select boxes are shown
    When I select "MySurvey" from "Registration type"
    And I sleep for 1
    Then I should not see any supplementary file blocks
    And I should see 1 file select

  Scenario: Correct supplementary file boxes are shown after a validation failure
    When I select "Test Survey" from "Registration type"
    And I press "Upload"
    Then I should see "Supplementary files"
    And I should see "If you wish, you can supply the following data as separate tables"
    And I should see 3 file selects
    And I should see file select "Multi1"
    And I should see file select "Multi2"
