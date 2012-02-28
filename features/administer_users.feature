Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I have the usual roles
    And I have users
      | email                          | first_name    | last_name |
      | first@intersect.org.au         | First         | User      |
      | administrator@intersect.org.au | Administrator | Superuser |
    And I have hospitals
      | state | name       | abbrev |
      | NSW   | Left Wing  | Left   |
      | NSW   | Right Wing | Right  |
      | Vic   | Only Wing  | OWing  |
    And I am logged in as "administrator@intersect.org.au"
    And "administrator@intersect.org.au" has role "Administrator"

  Scenario: View a list of users
    Given "first@intersect.org.au" is deactivated
    When I am on the list users page
    Then I should see "users" table with
      | First name    | Last name | Email                          | Role          | Status      |
      | Administrator | Superuser | administrator@intersect.org.au | Administrator | Active      |
      | First         | User      | first@intersect.org.au         |               | Deactivated |

  Scenario: View user details
    Given "first@intersect.org.au" has role "Data Provider"
    And I am on the list users page
    When I follow "View Details" for "first@intersect.org.au"
    Then I should see field "Email" with value "first@intersect.org.au"
    And I should see field "First name" with value "First"
    And I should see field "Last name" with value "User"
    And I should see field "Role" with value "Data Provider"
    And I should see field "Status" with value "Active"

  Scenario: Go back from user details
    Given I am on the list users page
    When I follow "View Details" for "administrator@intersect.org.au"
    And I follow "Back"
    Then I should be on the list users page

  Scenario: Edit role
    Given "first@intersect.org.au" has role "Data Provider"
    And I am on the list users page
    When I follow "View Details" for "first@intersect.org.au"
    And I follow "Edit Access Level"
    And I select "Administrator" from "Role"
    And I press "Save"
    Then I should be on the user details page for first@intersect.org.au
    And I should see that the "access level" update succeeded for first@intersect.org.au
    And I should see field "Role" with value "Administrator"

  Scenario: Edit role from list page
    Given "first@intersect.org.au" has role "Data Provider"
    And I am on the list users page
    When I follow "Edit Access Level" for "first@intersect.org.au"
    And I select "Administrator" from "Role"
    And I press "Save"
    Then I should be on the user details page for first@intersect.org.au
    And I should see that the "access level" update succeeded for first@intersect.org.au
    And I should see field "Role" with value "Administrator"

  Scenario: Cancel out of editing roles
    Given "first@intersect.org.au" has role "Data Provider"
    And I am on the list users page
    When I follow "View Details" for "first@intersect.org.au"
    And I follow "Edit Access Level"
    And I select "Administrator" from "Role"
    And I follow "Back"
    Then I should be on the user details page for first@intersect.org.au
    And I should see field "Role" with value "Data Provider"

  Scenario: Role should be mandatory when editing Role
    And I am on the list users page
    When I follow "View Details" for "first@intersect.org.au"
    And I follow "Edit Access Level"
    And I select "" from "Role"
    And I press "Save"
    Then I should see "Please select a role for the user."

  Scenario: Deactivate active user
    Given I am on the list users page
    When I follow "View Details" for "first@intersect.org.au"
    And I follow "Deactivate"
    Then I should see "The user has been deactivated"
    And I should see "Activate"

  Scenario: Activate deactivated user
    Given "first@intersect.org.au" is deactivated
    And I am on the list users page
    When I follow "View Details" for "first@intersect.org.au"
    And I follow "Activate"
    Then I should see "The user has been activated"
    And I should see "Deactivate"

  Scenario: Can't deactivate the last administrator account
    Given I am on the list users page
    When I follow "View Details" for "administrator@intersect.org.au"
    And I follow "Deactivate"
    Then I should see "You cannot deactivate this account as it is the only account with Administrator privileges."
    And I should see field "Status" with value "Active"

  Scenario: Editing own role has alert
    Given I am on the list users page
    When I follow "View Details" for "administrator@intersect.org.au"
    And I follow "Edit Access Level"
    Then I should see "You are changing the access level of the user you are logged in as."

  Scenario: Should not be able to edit role of rejected user by direct URL entry
    Given I have a rejected as spam user "spam@intersect.org.au"
    And I go to the edit role page for spam@intersect.org.au
    Then I should be on the list users page
    And I should see "Access level can not be set. This user has previously been rejected as a spammer."

##Scenarios relating to assigning a hospital to an approved user

  @javascript
  Scenario: Changing a user's role to superuser clears their hospital selection
    Given I am on the edit role page for first@intersect.org.au
    And I should see "Hospital"
    And I select "Administrator" from "Role"
    #capybarra still sees hidden things ><
#    Then I should not see "Hospital"
    And I press "Save"
    And I should see that the "access level" update succeeded for first@intersect.org.au
    And I should be on the user details page for first@intersect.org.au
    And I should not see "Hospital"

  @javascript
  Scenario: Changing a user's role from superuser to a regular role allows selection of a hospital
    Given I have a user "other_super@intersect.org.au" with role "Administrator"
    And I have role "other role"
    And I am on the edit role page for other_super@intersect.org.au
    #capybarra still sees hidden things ><
#    And I should not see "Hospital"
    And I select "other role" from "Role"
    Then I should see "Hospital"
    And I select "Left Wing" from "Hospital"
    And I press "Save"
    And I should see that the "access level" update succeeded for other_super@intersect.org.au
    And I should be on the user details page for other_super@intersect.org.au
    And I should see field "Hospital" with value "Left Wing (NSW)"

  Scenario: Changing a user's role from superuser to a regular role requires selection of a hospital
    Given I have a user "other_super@intersect.org.au" with role "Administrator"
    And I have role "other role"
    And I am on the edit role page for other_super@intersect.org.au
    And I select "other role" from "Role"
    And I select blank from "Hospital"
    And I press "Save"
    Then I should see "All non-superusers must be assigned a hospital"

    ##END Scenarios relating to assigning a hospital to an approved user

