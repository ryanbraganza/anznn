Feature: Approve access requests
  In order to allow users to access the system
  As an administrator
  I want to approve access requests

  Background:
    Given I have the usual roles
    And I have a user "administrator@intersect.org.au" with role "Administrator"
    And I have access requests
      | email                   | first_name | last_name |
      | first@intersect.org.au  | First      | User      |
      | second@intersect.org.au | Second     | User      |
    And I have hospitals
      | state | name       | abbrev |
      | NSW   | Left Wing  | Left   |
      | NSW   | Right Wing | Right  |
      | Vic   | Only Wing  | OWing  |
    And I am logged in as "administrator@intersect.org.au"

  Scenario: View a list of access requests
    Given I am on the access requests page
    Then I should see "access_requests" table with
      | First name | Last name | Email                   |
      | First      | User      | first@intersect.org.au  |
      | Second     | User      | second@intersect.org.au |

  Scenario: Approve an access request from the list page
    Given I am on the access requests page
    When I follow "Approve" for "second@intersect.org.au"
    And I select "Administrator" from "Role"
    And I press "Approve"
    Then I should see "The access request for second@intersect.org.au was approved."
    And I should see "access_requests" table with
      | First name | Last name | Email                  |
      | First      | User      | first@intersect.org.au |
    And "second@intersect.org.au" should receive an email with subject "ANZNN - Your access request has been approved"
    When they open the email
    Then they should see "You made a request for access to the ANZNN System. Your request has been approved. Please visit" in the email body
    And they should see "Hello Second User," in the email body
    When they click the first link in the email
    Then I should be on the home page

  Scenario: Cancel out of approving an access request from the list page
    Given I am on the access requests page
    When I follow "Approve" for "second@intersect.org.au"
    And I select "Administrator" from "Role"
    And I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name | Email                   |
      | First      | User      | first@intersect.org.au  |
      | Second     | User      | second@intersect.org.au |

  Scenario: View details of an access request
    Given I am on the access requests page
    When I follow "View Details" for "second@intersect.org.au"
    Then I should see "second@intersect.org.au"
    Then I should see field "Email" with value "second@intersect.org.au"
    Then I should see field "First name" with value "Second"
    Then I should see field "Last name" with value "User"
    Then I should see field "Role" with value ""
    Then I should see field "Status" with value "Pending Approval"

  Scenario: Approve an access request from the view details page
    Given I am on the access requests page
    When I follow "View Details" for "second@intersect.org.au"
    And I follow "Approve"
    And I select "Administrator" from "Role"
    And I press "Approve"
    Then I should see "The access request for second@intersect.org.au was approved."
    And I should see "access_requests" table with
      | First name | Last name | Email                  |
      | First      | User      | first@intersect.org.au |

  Scenario: Cancel out of approving an access request from the view details page
    Given I am on the access requests page
    When I follow "View Details" for "second@intersect.org.au"
    And I follow "Approve"
    And I select "Administrator" from "Role"
    And I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name | Email                   |
      | First      | User      | first@intersect.org.au  |
      | Second     | User      | second@intersect.org.au |

  Scenario: Go back to the access requests page from the view details page without doing anything
    Given I am on the access requests page
    And I follow "View Details" for "second@intersect.org.au"
    When I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name | Email                   |
      | First      | User      | first@intersect.org.au  |
      | Second     | User      | second@intersect.org.au |

  Scenario: Role should be mandatory when approving an access request
    Given I am on the access requests page
    When I follow "Approve" for "second@intersect.org.au"
    And I press "Approve"
    Then I should see "Please select a role for the user."

  Scenario: Approved user should be able to log in
    Given I am on the access requests page
    When I follow "Approve" for "second@intersect.org.au"
    And I select "Administrator" from "Role"
    And I press "Approve"
    And I am on the home page
    And I follow "Logout"
    Then I should be able to log in with "second@intersect.org.au" and "Pas$w0rd"

  Scenario: Approved user roles should be correctly saved
    Given I am on the access requests page
    And I follow "Approve" for "second@intersect.org.au"
    And I select "Administrator" from "Role"
    And I press "Approve"
    And I am on the list users page
    When I follow "View Details" for "second@intersect.org.au"
    And I should see field "Role" with value "Administrator"


##Scenarios relating to assigning a hospital to an approved user

  @wip @javascript
  Scenario: Superusers aren't assigned to a hospital when approved
    pending "capybarra still sees hidden things"
    Given I am on the access requests page
    And I follow "Approve" for "second@intersect.org.au"
    And I select "Administrator" from "Role"
    Then I should not see "Hospital"

  @javascript
  Scenario: Non-superusers must be assigned to a hospital when approved
    Given I am on the access requests page
    And I follow "Approve" for "second@intersect.org.au"
    And I select "Data Provider" from "Role"
    Then I should see "Hospital"
    And I select "Left Wing" from "Hospital"
    And I press "Approve"
    And I am on the list users page
    When I follow "View Details" for "second@intersect.org.au"
    And I should see field "Hospital" with value "Left Wing (NSW)"

    ##END Scenarios relating to assigning a hospital to an approved user
