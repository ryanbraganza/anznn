Feature: Cross Question Present-If-Constant Validations
  In order to ensure data is correct
  As a system owner
  I want answers validated such that Question B must be answered if Question A equals a certain value

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question   | question_type |
      | Date Q1    | Date          |
      | Choice Q1  | Choice        |
      | Integer Q1 | Integer       |
    And question "Choice Q1" has question options
      | option_value | label |
      | 99           | Dunno |
      | -1           | Yes   |
      | 1            | No    |
    And I have the following cross question validations
      | question  | related | rule                  | error_message                      | operator | constant |
      | Choice Q1 | Date Q1 | const_implies_present | date should be present if q1 is -1 | ==       | -1       |
    And I am ready to enter responses as data.provider@intersect.org.au

  Scenario: If one answer = -1, another must also be present (choice and date) - pass (choice is -1 and date is answered)
    When I store the following answers
      | question  | answer     |
      | Date Q1   | 2009/12/23 |
      | Choice Q1 | (-1) Yes   |
    Then I should not see "date should be present if q1 is -1"

  Scenario: If one answer = -1, another must also be present (choice and date) - pass (choice is NOT -1 and date NOT answered)
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (99) Dunno |
    Then I should not see "date should be present if q1 is -1"

  Scenario: If one answer = -1, another must also be present (choice and date) - pass (neither answered)
    When I store the following answers
      | question   | answer |
      | Integer Q1 | 3      |
    Then I should not see "date should be present if q1 is -1"

  Scenario: If one answer = -1, another must also be present (choice and date) - fail (choice is -1 and date NOT answered)
    When I store the following answers
      | question  | answer   |
      | Choice Q1 | (-1) Yes |
    Then I should see "date should be present if q1 is -1"

  Scenario: If one answer = -1, another must also be present (choice and date) - fail (choice is -1 and date invalid)
    When I store the following answers
      | question  | answer   |
      | Date Q1   | 2009/12/ |
      | Choice Q1 | (-1) Yes |
    Then I should see "date should be present if q1 is -1"

