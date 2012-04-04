Feature: Managing responses
  In order to see the status of my survey responses
  As a data provider
  I want response information readily available.

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    Given I have a user "other.provider@intersect.org.au" with role "Data Provider" and hospital "Other"

  Scenario: Home page should be the survey list page
    When I am on the home page
    And I should see "Surveys In Progress"

  Scenario: See an informative message when there are no responses in progress
    When I am on the home page
    Then I should see "There are no surveys in progress."

  Scenario: See a list of incomplete surveys
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123" and year of registration "2009"
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode456" and year of registration "2011" and submitted it
    When I am on the home page
    And I should see "responses" table with
      | Baby Code   | Survey Type | Created By  | Year of Registration |
      | babycode123 | survey      | Fred Bloggs | 2009                 |

  Scenario: Edit a listed survey
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123"
    When I am on the home page
    And I follow "Edit"
    Then I should be on the response page for babycode123

  Scenario: View summary for a listed survey
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123"
    When I am on the home page
    And I follow "View Summary"
    Then I should be on the response summary page for babycode123

  Scenario: Data providers can only see surveys from their own hospital
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123"
    And "other.provider@intersect.org.au" created a response to the "survey" survey with babycode "babyother"
    And I am on the home page
    And I should see "responses" table with
      | Baby Code   | Survey Type | Created By  |
      | babycode123 | survey      | Fred Bloggs |
    When I go to the response page for babycode123
    Then I should be on the response page for babycode123
    When I go to the response page for babyother
    Then I should be on the home page
    And I should see the access denied error

  Scenario: Data provider supervisors can only see surveys from their own hospital
    Given I am logged in as "supervisor@intersect.org.au" and have role "Data Provider Supervisor" and I'm linked to hospital "RPA"
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123"
    And "other.provider@intersect.org.au" created a response to the "survey" survey with babycode "babyother"
    And I am on the home page
    And I should see "responses" table with
      | Baby Code   | Survey Type | Created By  |
      | babycode123 | survey      | Fred Bloggs |
    When I go to the response page for babycode123
    Then I should be on the response page for babycode123
    When I go to the response page for babyother
    Then I should be on the home page
    And I should see the access denied error

  Scenario: superusers can see all surveys
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123"
    And "other.provider@intersect.org.au" created a response to the "survey" survey with babycode "babyother"
    And I am logged in as "super@intersect.org.au" and have role "Administrator"
    When I am on the home page
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  |
      | babycode123 | survey      | Fred Bloggs |
      | babyother   | survey      | Fred Bloggs |
