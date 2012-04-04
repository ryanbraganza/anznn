Feature: View Stats
  In order to find out how data collection is progressing
  As an admin
  I want to see a breakdown by survey, hospital and year of registration

  Background:
    Given I have the usual roles
    And I have a user "admin@intersect.org.au" with role "Administrator"
    And I have year of registration range configured as "2000" to "2010"
    And I have hospitals
      | name                         | state |
      | RPA                          | NSW   |
      | Royal North Shore            | NSW   |
      | Mercy Hospital               | Vic   |
      | The Royal Childrens Hospital | Vic   |
      | Sydney Childrens Hospital    | NSW   |
      | Another One                  | NSW   |
    And I have a survey with name "Survey A"
    And I have a survey with name "Survey B"
    And I have a survey with name "Survey None"
  # Its going to be a bit verbose to create them all here, so jump into the step to see what it creates
    And I have a range of responses
    And I am logged in as "admin@intersect.org.au"

  Scenario: Correct stats are shown on home page
    Given I am on the home page
    Then I should not see "Survey None"
    And I should see survey stats table for "Survey A" with
      |                              | 2009 In Progress | 2009 Submitted | 2010 In Progress | 2010 Submitted | 2011 In Progress | 2011 Submitted |
      | NSW                          |                  |                |                  |                |                  |                |
      | Another One                  | none             | none           | none             | none           | none             | none           |
      | RPA                          | 5                | 3              | 3                | none           | 4                | 8              |
      | Royal North Shore            | none             | none           | none             | none           | none             | none           |
      | Sydney Childrens Hospital    | 1                | 1              | 1                | 2              | 1                | 3              |
      | Vic                          |                  |                |                  |                |                  |                |
      | Mercy Hospital               | 1                | 3              | 2                | none           | 3                | 8              |
      | The Royal Childrens Hospital | 6                | none           | 8                | none           | 10               | 2              |
    And I should see survey stats table for "Survey B" with
      |                              | 2009 In Progress | 2009 Submitted | 2010 In Progress | 2010 Submitted | 2011 In Progress | 2011 Submitted |
      | NSW                          |                  |                |                  |                |                  |                |
      | Another One                  | none             | none           | none             | none           | none             | none           |
      | RPA                          | none             | none           | none             | 1              | 2                | 6              |
      | Royal North Shore            | none             | 12             | none             | 3              | 2                | 2              |
      | Sydney Childrens Hospital    | none             | none           | none             | none           | 1                | none           |
      | Vic                          |                  |                |                  |                |                  |                |
      | Mercy Hospital               | none             | none           | none             | 1              | none             | 6              |
      | The Royal Childrens Hospital | none             | none           | none             | none           | none             | none           |

  Scenario: Data providers don't see stats
    Given I am logged in as "dp@intersect.org.au" and have role "Data Provider"
    Then I should not see "Data Collection Stats"

  Scenario: Data provider supervisors don't see stats
    Given I am logged in as "dp@intersect.org.au" and have role "Data Provider Supervisor"
    Then I should not see "Data Collection Stats"
