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
    And I should have 111 responses

  Scenario: Admin can batch delete respones
    When I follow "Admin"
    And I follow "Delete Responses"
    And I select "2009" from "Year of registration"
    And I select "Survey A" from "Registration type"
    And I press "Next"
    Then I should see "WARNING"
    And I should see "This will affect 20 records."
    When I press "confirm_delete"
    Then survey "Survey A" should have no responses for year "2009"
    And I should have 91 responses
    And I should see "The records were deleted"

  Scenario: Must select a survey to get a download
    When I follow "Admin"
    And I follow "Delete Responses"
    When I select "2009" from "Year of registration"
    And I press "Next"
    Then I should see "Please select a registration type" within the form errors
    And "2009" should be selected in the "Year of registration" select

  Scenario: Must select a year of registration to get a download
    When I follow "Admin"
    And I follow "Delete Responses"
    When I select "Survey A" from "Registration type"
    And I press "Next"
    Then I should see "Please select a year of registration" within the form errors
    And "Survey A" should be selected in the "Registration type" select

