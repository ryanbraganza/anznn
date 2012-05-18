Feature: Cross Question One-Of-Present-If-Constant Validations
  In order to ensure data is correct
  As a system owner
  I want answers validated such that one of a range of questions must have a particular value if Question A equals a certain value

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question  | question_type | code |
      | Choice Q1 | Choice        | C1   |
      | Choice Q2 | Choice        | C2   |
      | Choice Q3 | Choice        | C3   |
      | Choice Q4 | Choice        | C4   |
    And question "Choice Q1" has question options
      | option_value | label |
      | 99           | Dunno |
      | -1           | Yes   |
      | 1            | No    |
    And question "Choice Q2" has question options
      | option_value | label |
      | 99           | Dunno |
      | -1           | Yes   |
      | 1            | No    |
    And question "Choice Q3" has question options
      | option_value | label |
      | 99           | Dunno |
      | -1           | Yes   |
      | 1            | No    |
    And question "Choice Q4" has question options
      | option_value | label |
      | 99           | Dunno |
      | -1           | Yes   |
      | 1            | No    |
    And I have the following cross question validations
      | question | related_question_list | rule                       | error_message                            | operator | constant | conditional_operator | conditional_constant |
      | C1       | C2, C3, C4            | const_implies_one_of_const | one of C2, C3, C4 must be 99 if C1 is -1 | ==       | -1       | ==                   | 99                   |
    And I am ready to enter responses as data.provider@intersect.org.au

  Scenario: Pass: C1 is -1 and C3 is 99
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (-1) Yes   |
      | Choice Q3 | (99) Dunno |
      | Choice Q4 | (-1) Yes   |
    Then I should not see "one of C2, C3, C4 must be 99 if C1 is -1"

  Scenario: Pass: C1 not answered
    When I store the following answers
      | question  | answer   |
      | Choice Q3 | (-1) Yes |
      | Choice Q4 | (-1) Yes |
    Then I should not see "one of C2, C3, C4 must be 99 if C1 is -1"

  Scenario: Pass: C1 not -1
    When I store the following answers
      | question  | answer     |
      | Choice Q1 | (99) Dunno |
      | Choice Q3 | (-1) Yes   |
      | Choice Q4 | (-1) Yes   |
    Then I should not see "one of C2, C3, C4 must be 99 if C1 is -1"

  Scenario: Fail: C1 is -1 and no others answered
    When I store the following answers
      | question  | answer   |
      | Choice Q1 | (-1) Yes |
    Then I should see "one of C2, C3, C4 must be 99 if C1 is -1"

  Scenario: Fail: C1 is -1 and others are answered but none are 99
    When I store the following answers
      | question  | answer   |
      | Choice Q1 | (-1) Yes |
      | Choice Q2 | (-1) Yes |
      | Choice Q3 | (-1) Yes |
      | Choice Q4 | (-1) Yes |
    Then I should see "one of C2, C3, C4 must be 99 if C1 is -1"

