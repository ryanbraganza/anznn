Feature: Home page
  In order to see the status of my survey responses and batch files
  As a data provider
  I want sensible navigation from the home page

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    Given I have a user "other.provider@intersect.org.au" with role "Data Provider" and hospital "Other"
    Given I have a user "data.supervisor@intersect.org.au" with role "Data Provider Supervisor" and hospital "RPA"
    Given I have a user "admin@intersect.org.au" with role "Administrator"

  Scenario Outline: For data providers and supervisors, home page should have responses and batch uploads tabs and should default to responses
    Given I am logged in as "<user>"
    When I am on the home page
    Then I should see "Surveys In Progress"
    And I should see link "Batch Uploads"
    And I should not see link "Stats"
    When I follow "Batch Uploads"
    Then I should be on the list of batch uploads page
    When I follow "Responses"
    Then I should be on the home page
  Examples:
    | user                             |
    | data.provider@intersect.org.au   |
    | data.supervisor@intersect.org.au |

  Scenario: For administrators, home page should have responses, batch uploads and stats tabs and should default to responses
    Given I am logged in as "admin@intersect.org.au"
    When I am on the home page
    Then I should see "Surveys In Progress"
    And I should see link "Batch Uploads"
    And I should see link "Stats"
    When I follow "Batch Uploads"
    Then I should be on the list of batch uploads page
    When I follow "Stats"
    Then I should be on the stats page
    When I follow "Responses"
    Then I should be on the home page

