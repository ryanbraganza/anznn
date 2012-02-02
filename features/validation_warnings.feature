Feature: Show warnings on survey pages
  In order to fill in the survey correctly and quickly
  As a data provider
  I want to see warning info when I've entered something incorrectly

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question   | question_type | number_min | number_max | number_unknown | string_min | string_max |
      | Text Q1    | Text          |            |            |                | 5          | 10         |
      | Text Q2    | Text          |            |            |                | 5          | 100        |
      | Integer Q1 | Integer       | -100       | 500        |                |            |            |
      | Integer Q2 | Integer       | 0          | 5          |                |            |            |
      | Decimal Q  | Decimal       |            | 10         | 99             |            |            |
      | Date Q     | Date          |            |            |                |            |            |
      | Time Q     | Time          |            |            |                |            |            |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey

  Scenario: Viewing warnings for valid (but out-of-range) data after saving
    Given I am on the edit first response page
    Then I should see no warnings
    When I answer "Text Q1" with "areallylongstring"
    When I answer "Text Q2" with "iam9chars"
    And I answer "Integer Q1" with "1000"
    And I answer "Decimal Q" with "20.5"
    And I answer "Integer Q2" with "3"
    And I press "Save"
    Then I should see warning "Answer should be between 5 and 10 characters" for question "Text Q1"
    Then I should see warning "Answer should be between -100 and 500" for question "Integer Q1"
    Then I should see warning "Answer should be a maximum of 10 or 99 for unknown" for question "Decimal Q"
    And "Integer Q2" should have no warning
    And "Text Q2" should have no warning


  Scenario Outline: View warnings for invalid data after saving (Incomplete dates/times, invalid dates)
    Given I am on the edit first response page
    Then I should see no warnings
    And I answer "<question>" with "<value>"
    And I press "Save"
    Then I should see warning "<warning>" for question "<question>"

  @wip
  Scenarios: View warnings for invalid data after saving (Strings in int/decimal fields)
    | question   | value | warning                                               |
    | Integer Q1 | abcd  | Answer is the wrong format (Expected an integer)      |
    | Decimal Q  | abcd  | Answer is the wrong format (Expected a decimal value) |

  @wip
  Scenarios:  View warnings for invalid data after saving (Incomplete dates/times, invalid dates)
    | question | value | warning                                          |
    | Date Q   | abcd  | Answer is incomplete (Day field blank)           |
    | Date Q   | abcd  | Answer is incomplete (Month field blank)         |
    | Date Q   | abcd  | Answer is incomplete (Year field blank)          |
    | Date Q   | abcd  | Answer is invalid (Provided date does not exist) |
    | Time Q   | abcd  | Answer is incomplete (Hour field blank)          |
    | Time Q   | abcd  | Answer is incomplete (Minute field blank)        |

