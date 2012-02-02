Feature: Managing responses
  In order to see the status of my survey responses
  As a data provider
  I want response information readily available.

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"

  Scenario: Home page should be the survey list page
    When I am on the home page
    Then I should see "Survey Responses"
    And I should see "Surveys In Progress"

  Scenario: See an informative message when there are no responses in progress
    When I am on the home page
    Then I should see "There are no surveys in progress. To start a new one, click the 'Start New Survey Response' link above."

  Scenario: See a list of incomplete surveys
    Given I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    And "data.provider@intersect.org.au" created a response to the "survey" survey
    When I am on the home page
    And I should see "responses" table with
      | Baby Code   | Survey Type | Created By  |
      | babycode123 | survey      | Fred Bloggs |

  Scenario: Edit a listed survey
    Given I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    And "data.provider@intersect.org.au" created a response to the "survey" survey
    When I am on the list of responses page
    And I follow "Edit"
    Then I should be on the response page for babycode123

  Scenario: View summary for a listed survey
    Given I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    And "data.provider@intersect.org.au" created a response to the "survey" survey
    When I am on the list of responses page
    And I follow "View Summary"
    Then I should be on the response summary page for babycode123