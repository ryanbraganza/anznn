Feature: Cross Question Present-If-In-Set Validations
  In order to ensure data is correct
  As a system owner
  I want answers validated such that Question B must be answered if Question A falls within a range

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
      | 1            | One    |
      | 2            | Two    |
      | 5            | Five    |
      | 7            | Seven    |
      | 99           | Dunno |
    And I have the following cross question validations
      | question  | related | rule                  | error_message                      | set_operator | set |
      | Choice Q1 | Date Q1 | set_implies_present | date should be present if q1 is between 2 and 7 | range       | [2, 7]       |
    And I am ready to enter responses as data.provider@intersect.org.au

  Scenario: If one answer within range 2-7, another must also be present - pass (value 2 (start of range) and other question is answered)
    When I store the following answers
      | question  | answer     |
      | Date Q1   | 2009/12/23 |
      | Choice Q1 | (2) Two   |
    Then I should not see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - pass (value 7 (end of range) and other question is answered)
    When I store the following answers
      | question  | answer     |
      | Date Q1   | 2009/12/23 |
      | Choice Q1 | (7) Seven   |
    Then I should not see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - pass (value 5 (mid range) and other question is answered)
    When I store the following answers
      | question  | answer     |
      | Date Q1   | 2009/12/23 |
      | Choice Q1 | (5) Five   |
    Then I should not see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - fail (value 2 (start of range) and other question NOT answered)
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (2) Two   |
    Then I should see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - fail (value 7 (end of range) and other question NOT answered)
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (7) Seven   |
    Then I should see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - fail (value 5 (mid range) and other question NOT answered)
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (5) Five   |
    Then I should see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - pass (choice is NOT in 2-7 and date NOT answered)
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (99) Dunno |
    Then I should not see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - pass (neither answered)
    When I store the following answers
      | question   | answer |
      | Integer Q1 | 3      |
    Then I should not see "date should be present if q1 is between 2 and 7"

  Scenario: If one answer within range 2-7, another must also be present - fail (value 7 (end of range) and date invalid)
    When I store the following answers
      | question  | answer   |
      | Date Q1   | 2009/12/ |
      | Choice Q1 | (2) Two |
    Then I should see "date should be present if q1 is between 2 and 7"

