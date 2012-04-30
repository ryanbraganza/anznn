Feature: Navigating the site
  In order to get my work done
  As a user
  I want to be able to find the things I need

  Background:
    Given I have the usual roles
    And I have a user "super@intersect.org.au" with role "Administrator"
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"

  Scenario: When not logged in, home page should contain login area, forgot password link and signup link
    When I am on the home page
    Then I should see "Please enter your email and password to log in"
    And I should see link "Forgot your password?"
    And I should see link "Request An Account"

  Scenario: When not logged in, home link should point back to home page with login box
    When I am on the home page
    And I follow "Request An Account"
    And I follow "Home"
    Then I should be on the home page
    When I follow "Forgot your password?"
    And I follow "Home"
    Then I should be on the home page
    And I should not see "Data Entry Forms In Progress"

  Scenario: When logged in, home link should be the list of surveys
    Given I am logged in as "data.provider@intersect.org.au"
    When I follow "Home"
    Then I should be on the home page
    And I should see "Data Entry Forms In Progress"

  Scenario: Nav links visible to administrators (Admin, Chg pwd, Chg details, Logout)
    Given I am logged in as "super@intersect.org.au"
    Then I should see link "Admin"
    And I should see link "super@intersect.org.au"
    And I should see link "Logout"

  Scenario: Nav links visible to data providers (Chg pwd, Chg details, Logout)
    Given I am logged in as "data.provider@intersect.org.au"
    Then I should not see link "Admin"
    And I should see link "data.provider@intersect.org.au"
    And I should see link "Logout"


