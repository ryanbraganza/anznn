Feature: Cross Question Special Rules
  In order to ensure data is correct
  As a system owner
  I want the answers to questions with unusual dependencies to be validated correctly

#  10 B O2_36wk_
#    if is -1 then: Gest must be <32 or Wght must be <1500 [multi_if_then (comparison, special_dual_comparison]
#    if is -1 then: Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36 [multi_if_then (comparison,special_o2_a)**]
#       )
#  10 B HmeO2    -
#       if is -1 then: [multi_if_then (
#           comparison, mutli_rule_all_pass (
#                (Gest must be <32 or Wght must be <1500) [special_dual_comparison] **
#                HomeDate must be a date [blank_unless_date] **
#                HomeDate must be the same as LastO2 [comparison]
#           )
#       )

#  DOB must be in year of registration [special_dob] **
#  Weeks(This, DOB) must be 4<=This<=8 16 A16c USd6wk [comparison_range_weeks] **
#  Days(This, Linf1) must be >14  11 B11c Date_Linf2 [comparison_const_days] **

#  ** = New Rule

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question       | question_type |
      | Num Q1         | Integer       |
      | Num Q2         | Integer       |
      | Wght           | Decimal       |
      | Gest           | Integer       |
      | GestDays       | Integer       |
      | DOB            | Date          |
      | HomeDate       | Date          |
      | LastO2         | Date          |
      | CeaseCPAPDate  | Date          |
      | CeaseHiFloDate | Date          |



####################

#      | question | related | related_question_list                                      | rule_label_list                | rule_label        | rule                    | error_message                            | operator | constant | conditional_operator | conditional_constant | comments                                                                                              |
#      | Gest     | Wght    |                                                            |                                | gest_wght_comp    | special_dual_comparison |                                          | <        | 32       | <                    | 1500                 | only needs to be implemented once, both are required fields so survey can't be submitted if one blank |
#      | DOB      | DOB     |                                                            |                                |                   | special_dob             | dob must be in reg year                  |          |          |                      |                      |                                                                                                       |
#      | Num Q1   |         | Gest, GestDays, DOB, LastO2, CeaseCPAPDate, CeaseHiFloDate |                                | special_o2_a_if   | self_comparison         |                                          |          |          |                      |                      |                                                                                                       |
#      | Num Q1   |         | Gest, GestDays, DOB, LastO2, CeaseCPAPDate, CeaseHiFloDate |                                | special_o2_a_then | special_o2_a            |                                          |          |          |                      |                      |                                                                                                       |

  Scenario: CQV Failure - Special_O2_A -  Gest must be <32 or Wght must be <1500  when this = -1
    Given I have the following cross question validations
      | question | related | related_question_list | rule_label_list                 | rule_label      | rule                    | error_message                            | operator | constant | conditional_operator | conditional_constant | comments                                                                                              |
      | Gest     | Wght    |                       |                                 | gest_wght_comp  | special_dual_comparison |                                          | <        | 32       | <                    | 1500                 | only needs to be implemented once, both are required fields so survey can't be submitted if one blank |
      | Num Q1   | Num Q1  |                       |                                 | special_o2_a_if | self_comparison         |                                          | ==       | -1       |                      |                      |                                                                                                       |
      | Num Q1   |         |                       | special_o2_a_if, gest_wght_comp |                 | multi_rule_if_then      | this was -1; gest/weight don't meet reqs |          |          |                      |                      |                                                                                                       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | -1     |
      | Wght     | 1599   |
      | Gest     | 3300   |
    Then I should see "this was -1; gest/weight don't meet reqs"

  Scenario: CQV Failure - Special_O2_A - (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36 when this = -1
    Given I have the following cross question validations
      | question | related | related_question_list                                      | rule_label_list                    | rule_label        | rule               | error_message                  | operator | constant | conditional_operator | conditional_constant | comments |
      | Num Q1   | Num Q1  |                                                            |                                    | special_o2_a_if   | self_comparison    |                                | ==       | -1       |                      |                      |          |
      | Num Q1   |         | Gest, GestDays, DOB, LastO2, CeaseCPAPDate, CeaseHiFloDate |                                    | special_o2_a_then | special_o2_a       |                                |          |          |                      |                      |          |
      | Num Q1   |         |                                                            | special_o2_a_if, special_o2_a_then |                   | multi_rule_if_then | this was -1; special_o2_a fail |          |          |                      |                      |          |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question       | answer   |
      | Num Q1         | -1       |
      | DOB            | 2012/1/1 |
      | Gest           | 1        |
      | Gestdays       | 6        |
      | LastO2         | 2012/1/4 |
      | CeaseCPAPDate  | 2012/1/3 |
      | CeaseHiFloDate | 2012/1/2 |
    Then I should see "this was -1; special_o2_a fail"

  Scenario: CQV Pass - Special_O2_A - Both cases
    Given I have the following cross question validations
      | question | related | related_question_list                                      | rule_label_list                    | rule_label        | rule                    | error_message                            | operator | constant | conditional_operator | conditional_constant | comments                                                                                              |
      | Num Q1   | Num Q1  |                                                            |                                    | special_o2_a_if   | self_comparison         |                                          | ==       | -1       |                      |                      |                                                                                                       |
      | Gest     | Wght    |                                                            |                                    | gest_wght_comp    | special_dual_comparison |                                          | <        | 32       | <                    | 1500                 | only needs to be implemented once, both are required fields so survey can't be submitted if one blank |
      | Num Q1   |         | Gest, GestDays, DOB, LastO2, CeaseCPAPDate, CeaseHiFloDate |                                    | special_o2_a_then | special_o2_a            |                                          |          |          |                      |                      |                                                                                                       |
      | Num Q1   |         |                                                            | special_o2_a_if, gest_wght_comp    |                   | multi_rule_if_then      | this was -1; gest/weight don't meet reqs |          |          |                      |                      |                                                                                                       |
      | Num Q1   |         |                                                            | special_o2_a_if, special_o2_a_then |                   | multi_rule_if_then      | this was -1; special_o2_a fail           |          |          |                      |                      |                                                                                                       |


    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question       | answer   |
      | Num Q1         | -1       |
      | DOB            | 2012/1/1 |
      | Wght           | 1499     |
      | Gest           | 31       |
      | Gestdays       | 6        |
      | LastO2         | 2012/1/2 |
      | CeaseCPAPDate  | 2012/1/3 |
      | CeaseHiFloDate | 2012/3/4 |
    Then I should not see "this was -1; special_o2_a fail"
    Then I should not see "this was -1; gest/weight don't meet reqs"


#################

  @wip
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

  @wip
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

  @wip
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

  @wip
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

  @wip
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
