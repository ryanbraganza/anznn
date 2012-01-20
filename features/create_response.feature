Feature: Create Response
  In order to enter data
  As a data provider
  I want to start a new survey and save my answers

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a simple survey

  Scenario: Creating a response
    Given I am logged in as "data.provider@intersect.org.au"
    When I am on the new response page
    And I fill in "Baby code" with "ABC123"
    And I press "Save Survey"
    Then I should see "Survey created"
