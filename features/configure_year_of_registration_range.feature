Feature: Configuring the range of allowed years for year of registration
  In order to get the data we want
  As an ANZNN administrator
  I want to configure the possible years for the year of registration dropdown

  Background:
    Given I am logged in as "admin@intersect.org.au" and have role "Administrator"
    And I have year of registration range configured as "2001" to "2012"
    And I follow "Admin"
    And I follow "Year of Registration Configuration"

  Scenario: Must enter both
    Given I fill in the year of registration range with "" and ""
    Then I should see "Start year is required" within the form errors
    And I should see "End year is required" within the form errors

  Scenario: Must be numbers
    Given I fill in the year of registration range with "af" and "33ff"
    Then I should see "Start year must be a number" within the form errors
    And I should see "End year must be a number" within the form errors

  Scenario: Must be integers
    Given I fill in the year of registration range with "22.22" and "44.44"
    Then I should see "Start year must be a number" within the form errors
    And I should see "End year must be a number" within the form errors

  Scenario: Start must be on or before end
    Given I fill in the year of registration range with "2001" and "2000"
    Then I should see "End year must be equal to or after start year" within the form errors

  Scenario: Successful save
    Given I fill in the year of registration range with "2005" and "2011"
    Then I should see "Year of registration range updated successfully."
    And the "Start year" field should contain "2005"
    And the "End year" field should contain "2011"

  Scenario: Successful save with same value
    Given I fill in the year of registration range with "2005" and "2005"
    Then I should see "Year of registration range updated successfully."
    And the "Start year" field should contain "2005"
    And the "End year" field should contain "2005"

  Scenario: Data providers and can't get to the page or update the values
    Given I am logged in as "dp@intersect.org.au" and have role "Data Provider"
    Then I should get a security error when I visit the configure year of registration range page
    And I should get a security error when I try to put to the configure year of registration range page
