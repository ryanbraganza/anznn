Feature: Managing responses
  In order to see the status of my survey responses
  As a data provider
  I want response information readily available.

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I am logged in as "data.provider@intersect.org.au"


  Scenario: See a summary of active survey responses
    When I am on the home page
    And I follow "Surveys"
    Then I should be on the list of responses page
    And I should see "Incomplete Surveys you have started"

  Scenario: See an informative message when there are no responses in progress
    When I am on the list of responses page
    Then I should see "There are no incomplete survey responses. To start a new one, click the 'new' link above."

  Scenario: See an informative message when there are no responses in progress
    Given I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    And "data.provider@intersect.org.au" created a response to the "survey" survey
    When I am on the list of responses page
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
    And I follow "babycode123"
    Then I should be on the response page for babycode123