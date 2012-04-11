Feature: Cross Question Conditional Validations
  In order to ensure data is correct
  As a system owner
  I want answers to be conditionally validated based on the answers to other questions

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question | question_type |
      | Num Q1   | Integer       |
      | Num Q2   | Integer       |
      | Date Q1  | Date          |

  Scenario: CQV Failure - Date Implies Const, eg If Qx is a date then This <must be> <-1> [13 B, Hmegavage]
    Given I have the following cross question validations
      | question | related | rule                  | operator | constant | error_message                                |
      | Num Q1   | Date Q1 | date_implies_constant | ==       | -1       | Date entered in Date Q1, this needs to be -1 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Num Q1   | 0        |
    Then I should see "Date entered in Date Q1, this needs to be -1"

  Scenario: CQV Failure - Constant Implies Constant, eg If Qx > 0 then This must <not be> <0> [3A Birth Order]
    Given I have the following cross question validations
      | question | related | rule                | conditional_operator | conditional_constant | operator | constant | error_message                 |
      | Num Q1   | Num Q2  | const_implies_const | >                    | 0                    | !=       | 0        | NumQ2 > 0, so this can't be 0 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 5      |
    Then I should see "NumQ2 > 0, so this can't be 0"

  Scenario: CQV Failure - Constant Implies Set, eg If Qx > 0 then This must be <included in> set [a,b,c,d] [17 B17c Retmaturity]
    Given I have the following cross question validations
      | question | related | rule              | conditional_operator | conditional_constant | set_operator | set       | error_message                          |
      | Num Q1   | Num Q2  | const_implies_set | >                    | 0                    | included     | [1,3,5,7] | NumQ2 > 0, so this must one of 1,3,5,7 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 5      |
    Then I should see "NumQ2 > 0, so this must one of 1,3,5,7"

  Scenario: CQV Failure - Set Implies Constant, eg If Qx exists in some set [w,x,y,z] then This must <not be> <0> [17 B17c ROPRx]
    Given I have the following cross question validations
      | question | related | rule              | conditional_set_operator | conditional_set | operator | constant | error_message                             |
      | Num Q1   | Num Q2  | set_implies_const | included                 | [2,4,6,8]       | !=       | 0        | NumQ2 is in [2,4,6,8], so this can't be 0 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 2      |
    Then I should see "NumQ2 is in [2,4,6,8], so this can't be 0"

  Scenario: CQV Failure - Set Implies Set, eg If Qx exists in some set [w,x,y,z] then This must be <included in> [a,b,c,d] [17 B17c ROP_VEGF]
    Given I have the following cross question validations
      | question | related | rule            | conditional_set_operator | conditional_set | set_operator | set       | error_message                                             |
      | Num Q1   | Num Q2  | set_implies_set | included                 | [2,4,6,8]       | excluded     | [1,3,5,7] | NumQ2 is in [2,4,6,8], so this cannot be one of [1,3,5,7] |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | 1      |
      | Num Q2   | 2      |
    Then I should see "NumQ2 is in [2,4,6,8], so this cannot be one of [1,3,5,7]"

