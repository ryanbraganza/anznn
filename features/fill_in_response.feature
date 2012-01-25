Feature: Create Response
  In order to enter data
  As a data provider
  I want to start a new survey and save my answers

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a simple survey
    And "data.provider@intersect.org.au" created a response to a simple survey

  Scenario: Saving a response
    Given I am logged in as "data.provider@intersect.org.au"
    And I am on the edit first response page
    Then I should see the simple questions
    When I answer the simple questions
    And press "Save page"
    Then I should see "Saved page"
    And I should see the simple questions with my previous answers
