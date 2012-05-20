Feature: Cross Question Special Rules
  In order to ensure data is correct
  As a system owner
  I want the answers to questions with unusual dependencies to be validated correctly

#  10 B O2_36wk_
#    if is -1 then: Gest must be <32 or Wght must be <1500 [multi_if_then (comparison, special_dual_comparison**]
#    if is -1 then: Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36 [multi_if_then (comparison,special_o2_a)**]
#       )
#  10 B HmeO2    -
#    if is -1 then: Gest must be <32 or Wght must be <1500 [multi_if_then (comparison, special_dual_comparison**]
#    if is -1 then: HomeDate must be a date [multi_if_then (comparison, present_implies_present]
#    if is -1 then:  HomeDate must be the same as LastO2 [multi_if_then (comparison, comparison]


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
      | USd6wk         | Date          |



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

  Scenario:  CQV Failure - DOB out of year
    Given I have the following cross question validations
      | question | related | rule        | error_message                   |
      | dob      | dob     | special_dob | DOB not in year of registration |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey with babycode "babycode456" and year of registration "2012"
    And I am on the response page for babycode456
    When I store the following answers
      | question | answer   |
      | DOB      | 2011/1/1 |

    Then I should see "DOB not in year of registration"


  Scenario:  CQV Pass - DOB in year
    Given I have the following cross question validations
      | question | related | rule        | error_message                   |
      | dob      | dob     | special_dob | DOB not in year of registration |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey with babycode "babycode456" and year of registration "2012"
    And I am on the response page for babycode456
    When I store the following answers
      | question | answer   |
      | DOB      | 2012/1/1 |
    Then I should not see "DOB not in year of registration"

###################

  Scenario: CQV Fail - special_usd6wk_a - out of range (low)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_a        | Err - special_usd6wk_a | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 0        |
      | USd6wk   | 2012/1/1 |
      | DOB      | 2012/1/2 |
      | Wght     | 1499     |
      | Gest     | 31       |
    Then I should see "Err - special_usd6wk_a"

  Scenario: CQV Fail - special_usd6wk_a - out of range (high)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_a        | Err - special_usd6wk_a | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 0         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1499      |
      | Gest     | 31        |
    Then I should see "Err - special_usd6wk_a"

  Scenario: CQV Pass - special_usd6wk_a - out of range but Num Q1 not in range
    Given I have the following cross question validations
      | question | related | rule                    | error_message          | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_a        | Err - special_usd6wk_a | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 5         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1499      |
      | Gest     | 31        |
    Then I should not see "Err - special_usd6wk_a"

  Scenario: CQV Pass - special_usd6wk_a - out of range, Num Q1 in range but wght/gest don't meet conds
    Given I have the following cross question validations
      | question | related | rule                    | error_message          | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_a        | Err - special_usd6wk_a | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 4         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1600      |
      | Gest     | 33        |
    Then I should not see "Err - special_usd6wk_a"

  Scenario: CQV Pass - special_usd6wk_a - everything meets conds
    Given I have the following cross question validations
      | question | related | rule_label_list | rule_label     | rule                    | error                  | set_operator | set   | conditional_set_operator | conditional_set | set | operator | constant | conditional_operator | conditional_constant |
      | USd6wk   | Num Q1  | gest_wght_comp  |                | special_usd6wk_a        | Err - special_usd6wk_a | range        | [4,8] | range                    | [0,4]           |     |          |          |                      |                      |
      | Gest     | Wght    |                 | gest_wght_comp | special_dual_comparison |                        |              |       |                          |                 |     | <        | 32       | <                    | 1500                 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 4        |
      | USd6wk   | 2012/1/1 |
      | DOB      | 2012/2/1 |
      | Wght     | 1500     |
      | Gest     | 32       |
    Then I should not see "Err - special_usd6wk_a"


#####################

