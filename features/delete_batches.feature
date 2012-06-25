Feature: Delete batches of responses
  In order to I can clear out data that has been moved to the long-term-storage database
  As an ANZNN admin
  I want a way to delete batches of responses

  Background:
    Given I have the usual roles
    And I have a user "administrator@intersect.org.au" with role "Administrator"
    And I am logged in as "administrator@intersect.org.au"
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
    And I have a range of responses

  Scenario: Admin can batch delete respones
    When I follow "Admin"
    And I follow "Delete Responses"
    And I select "2009" from "Year of Registration"
    And I select "Survey A" from "Registration Type"
    And I press "Next"
    Then I should see "WARNING"
