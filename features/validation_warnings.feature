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
      | Date Q1    | Date          |            |            |                |            |            |
      | Date Q2    | Date          |            |            |                |            |            |
      | Date Q3    | Date          |            |            |                |            |            |
      | Date Q4    | Date          |            |            |                |            |            |
      | Time Q1    | Time          |            |            |                |            |            |
      | Time Q2    | Time          |            |            |                |            |            |
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


  Scenario: View warnings for invalid data after saving (Strings in int/decimal fields)
    Given I am on the edit first response page
    Then I should see no warnings
    And I answer as follows
      | question   | answer       |
      | Decimal Q  | abcd         |
      | Integer Q1 | abcd         |
      | Integer Q2 | 1.5          |
    And I press "Save"
    Then I should see warnings as follows
      | question   | warning                                               | fatal |
      | Decimal Q  | Answer is the wrong format (Expected a decimal value) | true  |
      | Integer Q1 | Answer is the wrong format (Expected an integer)      | true  |
      | Integer Q2 | Answer is the wrong format (Expected an integer)      | true  |

  Scenario:  View warnings for invalid data after saving (Incomplete dates/times, invalid dates)
    Given I am on the edit first response page
    Then I should see no warnings
    And I answer as follows
      | question   | answer       |
      | Date Q1    | 2011/12/Day  |
      | Date Q2    | 2011/Month/1 |
      | Date Q3    | Year/12/1    |
      | Date Q4    | 2011/2/31   |
      | Time Q1    | 14:Minute    |
      | Time Q2    | Hour:05      |
    And I press "Save"
    Then I should see warnings as follows
      | question   | warning                                               | fatal |
      | Date Q1    | Answer is incomplete (one or more fields left blank)  | true  |
      | Date Q2    | Answer is incomplete (one or more fields left blank)  | true  |
      | Date Q3    | Answer is incomplete (one or more fields left blank)  | true  |
      | Date Q4    | Answer is invalid (Provided date does not exist)      | true  |
      | Time Q1    | Answer is incomplete (a field was left blank)         | true  |
      | Time Q2    | Answer is incomplete (a field was left blank)         | true  |
