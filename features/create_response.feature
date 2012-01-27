Feature: Create Response
  In order to enter data
  As a data provider
  I want to start a new survey and save my answers

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "Survey B" and questions
      | question   |
      | Question B |
    And I have a survey with name "Survey A" and questions
      | question   |
      | Question A |

  Scenario: Creating a response
    Given I am logged in as "data.provider@intersect.org.au"
    When I create a response for "Survey A" with baby code "ABC123"
    Then I should see "Survey created"
    And I should see "Survey A - Baby Code ABC123"
    And I should see "Question A"
    And I should not see "Question B"

  Scenario: Correct survey types are in the dropdown
    Given I am logged in as "data.provider@intersect.org.au"
    When I am on the new response page
    Then the "Survey" select should contain
      | Please select |
      | Survey A      |
      | Survey B      |

  Scenario: Try to create without selecting survey type
    Given I am logged in as "data.provider@intersect.org.au"
    When I create a response for "Please select" with baby code "ABC123"
    Then I should see "Survey type can't be blank" within the form errors
