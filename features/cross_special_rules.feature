Feature: Cross Question Special Rules
  In order to ensure data is correct
  As a system owner
  I want the answers to questions with unusual dependencies to be validated correctly

#  10 B O2_36wk_
#       is -1 [comparison]
#       (Gest must be <32 or Wght must be <1500) [multi_rule_any_pass: comparison, comparison]
#       (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36 [Special_O2_A] **
#
#  10 B HmeO2    -
#       is -1 [comparison]
#       (Gest must be <32 or Wght must be <1500) [multi_rule_any_pass: comparison, comparison]
#       HomeDate must be a date [blank_unless_date] **
#       HomeDate must be the same as LastO2 [comparison]
#  DOB must be in year of registration [Special_DOB] **
#  Weeks(This, DOB) must be 4<=This<=8 16 A16c USd6wk [comparison_range] **

#  ** = New Rule
  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question       | question_type |
      | Num Q1         | Integer       |
      | Num Q2         | Integer       |
      | Weight         | Decimal       |
      | Gest           | Integer       |
      | GestDays       | Integer       |
      | DOB            | Date          |
      | HomeDate       | Date          |
      | LastO2         | Date          |
      | CeaseCPAPDate  | Date          |
      | CeaseHiFloDate | Date          |


  Scenario: CQV Failure - Blank Unless Constant - This Qn must be blank unless other question is a specified number
    Given I have the following cross question validations
      | question | related | rule               | conditional_operator | conditional_constant | error_message                  |
      | Num Q1   | Num Q2  | blank_unless_const | ==                   | -1                   | q2 was != -1, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q2   | 2      |
      | Num Q1   | 5      |
    Then I should see "q2 was != -1, q1 must be blank"

  Scenario: CQV Failure - Blank Unless Within Range N...M (exclusive) - This Qn must be blank unless other answer between N...M
    Given I have the following cross question validations
      | question | related | rule             | conditional_set_operator | conditional_set | error_message                                       |
      | Num Q1   | Num Q2  | blank_unless_set | between                  | [2,4,6,8]       | q2 was outside 0...99 (exclusive), q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q2   | -1     |
      | Num Q1   | 5      |
    Then I should see "q2 was outside 0...99 (exclusive), q1 must be blank"

  Scenario: CQV Pass - Blank Unless Constant - This Qn must be blank unless other question is a specified number
    Given I have the following cross question validations
      | question | related | rule               | conditional_operator | conditional_constant | error_message                  |
      | Num Q1   | Num Q2  | blank_unless_const | ==                   | -1                   | q2 was != -1, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q2   | -1     |
      | Num Q1   | 5      |
    Then I should not see "q2 was != -1, q1 must be blank"

  Scenario: CQV Pass - Blank Unless Within Range N...M (exclusive) - This Qn must be blank unless other answer between N...M
    Given I have the following cross question validations
      | question | related | rule             | conditional_set_operator | conditional_set | error_message                                       |
      | Num Q1   | Num Q2  | blank_unless_set | between                  | [2,4,6,8]       | q2 was outside 0...99 (exclusive), q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q2   | 6      |
      | Num Q1   | 5      |
    Then I should not see "q2 was outside 0...99 (exclusive), q1 must be blank"

  Scenario: CQV Failure - Blank Unless days(Some Qn) >= 60
    Given I have the following cross question validations
      | question | related_question_list | rule                    | conditional_operator | conditional_constant | error_message                 |
      | Num Q1   | DOB Qn, Date Q1       | blank_unless_days_const | >=                   | 60                   | q2 was < 60, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 5         |
      | DOB Qn   | 2012/1/1  |
      | Date Q1  | 2012/1/31 |
    Then I should see "q2 was < 60, q1 must be blank"

  Scenario: CQV Pass - Blank Unless days(Some Qn) >= 60
    Given I have the following cross question validations
      | question | related_question_list | rule                    | conditional_operator | conditional_constant | error_message                 |
      | Num Q1   | DOB Qn, Date Q1       | blank_unless_days_const | >=                   | 60                   | q2 was < 60, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 5        |
      | DOB Qn   | 2012/1/1 |
      | Date Q1  | 2012/4/1 |
    Then I should not see "q2 was < 60, q1 must be blank"
