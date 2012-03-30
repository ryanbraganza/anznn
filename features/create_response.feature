Feature: Create Response
  In order to enter data
  As a data provider
  I want to start a new survey and save my answers

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have year of registration range configured as "2000" to "2010"
    And I have a survey with name "Survey B" and questions
      | question   |
      | Question B |
    And I have a survey with name "Survey A" and questions
      | question   |
      | Question A |
    And I am logged in as "data.provider@intersect.org.au"

  Scenario: Creating a response
    When I create a response for "Survey A" with baby code "ABC123" and year of registration "2001"
    Then I should see "Survey created"
    And I should see "Survey A - Baby Code ABC123 - Year of Registration 2001"
    And I should see "Question A"
    And I should not see "Question B"

  Scenario: Correct survey types are in the dropdown
    When I am on the new response page
    Then the "Survey" select should contain
      | Please select |
      | Survey A      |
      | Survey B      |

  Scenario: Correct years are in the year of reg dropdown
    When I am on the new response page
    Then the "Year of registration" select should contain
      | Please select |
      | 2000          |
      | 2001          |
      | 2002          |
      | 2003          |
      | 2004          |
      | 2005          |
      | 2006          |
      | 2007          |
      | 2008          |
      | 2009          |
      | 2010          |

  Scenario: Try to create without selecting survey type
    When I create a response for "Please select" with baby code "ABC123"
    Then I should see "Survey type can't be blank" within the form errors

  Scenario: Try to create without selecting year of registration
    When I create a response for "Survey A" with baby code "ABC123" and year of registration "Please select"
    Then I should see "Year of registration can't be blank" within the form errors

  Scenario: Try to create with duplicate baby code
    Given I create a response for "Survey A" with baby code "ABC123"
    When I create a response for "Survey A" with baby code "ABC123"
    Then I should see "Baby code ABC123 has already been used." within the form errors

  Scenario: Try to create with duplicate baby code with surrounding spaces
    Given I create a response for "Survey A" with baby code "ABC123"
    When I create a response for "Survey A" with baby code " ABC123 "
    Then I should see "Baby code ABC123 has already been used." within the form errors

  Scenario: Responses should be ordered by baby code on the home page
    Given I create a response for "Survey A" with baby code "C"
    Given I create a response for "Survey A" with baby code "D"
    Given I create a response for "Survey A" with baby code "B"
    Given I create a response for "Survey A" with baby code "A"
    Given I create a response for "Survey A" with baby code "AB"
    When I am on the home page
    Then I should see "responses" table with
      | Baby Code |
      | A         |
      | AB        |
      | B         |
      | C         |
      | D         |
