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
      | Date Q1        | Date          |
      | Date Q2        | Date          |
      | O2_36wk_      | Integer       |
      | HmeO2          | Integer       |



####################
# If O2_36wk_ is -1 and (Gest must be <32 or Wght must be <1500) then (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36

  Scenario: CQV Pass - Special_O2_A - if this = -1, process iff (Gest <32 or Wght  <1500 )
    Given I have the following cross question validations
      | question  | related   | rule         | error_message |
      | O2_36wk_ | O2_36wk_ | special_o2_a | o2a_err       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question  | answer |
      | O2_36wk_ | -1     |
      | Wght      | 1599   |
      | Gest      | 33     |
    Then I should not see "o2a_err"

  Scenario: CQV Failure - Special_O2_A - (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36 when this = -1
    Given I have the following cross question validations
      | question  | related   | rule         | error_message |
      | O2_36wk_ | O2_36wk_ | special_o2_a | o2a_err       |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question       | answer   |
      | O2_36wk_      | -1       |
      | DOB            | 2012/1/1 |
      | Gest           | 1        |
      | Wght           | 1        |
      | Gestdays       | 1        |
      | LastO2         | 2012/1/2 |
      | CeaseCPAPDate  | 2012/1/2 |
      | CeaseHiFloDate | 2012/1/2 |
    Then I should see "o2a_err"

  Scenario: CQV Pass - Special_O2_A - Both cases
    Given I have the following cross question validations
      | question  | related   | rule         | error_message |
      | O2_36wk_ | O2_36wk_ | special_o2_a | o2a_err       |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question       | answer   |
      | O2_36wk_      | -1       |
      | DOB            | 2012/1/1 |
      | Wght           | 1499     |
      | Gest           | 31       |
      | Gestdays       | 6        |
      | LastO2         | 2012/1/2 |
      | CeaseCPAPDate  | 2012/3/4 |
      | CeaseHiFloDate | 2012/1/2 |
    Then I should not see "o2a_err"


#################
# If HmeO2 is -1 and (Gest must be <32 or Wght must be <1500) and HomeDate must be a date and HomeDate must be the same as LastO2

  Scenario: CQV Pass - Special_HmeO2 - if this != -1 all is fine
    Given I have the following cross question validations
      | question | related | rule          | error_message |
      | HmeO2    | HmeO2   | special_hmeo2 | o2b_err       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | HmeO2    | 1      |
      | Wght     | 1499   |
      | Gest     | 31     |
    Then I should not see "oba_err"

  Scenario: CQV Pass - Special_HmeO2 - if this = -1, process iff (Gest <32 or Wght  <1500 )
    Given I have the following cross question validations
      | question | related | rule          | error_message |
      | HmeO2    | HmeO2   | special_hmeo2 | o2b_err       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | HmeO2    | -1     |
      | Wght     | 1599   |
      | Gest     | 33     |
    Then I should not see "oba_err"

  Scenario: CQV Failure - Special_HmeO2 - If HmeO2 is -1 and (Gest must be <32 or Wght must be <1500) then HomeDate must be present
    Given I have the following cross question validations
      | question | related | rule          | error_message |
      | HmeO2    | HmeO2   | special_hmeo2 | o2b_err       |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | HmeO2    | -1     |
      | Gest     | 1      |
      | Wght     | 1      |
    Then I should see "o2b_err"


  Scenario: CQV Failure - Special_HmeO2 - If HmeO2 is -1 and (Gest must be <32 or Wght must be <1500) then HomeDate must be a valid date
    Given I have the following cross question validations
      | question | related | rule          | error_message |
      | HmeO2    | HmeO2   | special_hmeo2 | o2b_err       |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | HmeO2    | -1        |
      | HomeDate | 2012/2/31 |
      | Gest     | 1         |
      | Wght     | 1         |
    Then I should see "o2b_err"

  Scenario: CQV Failure - Special_HmeO2 - If HmeO2 is -1 and (Gest must be <32 or Wght must be <1500) then HomeDate must be the same as LastO2
    Given I have the following cross question validations
      | question | related | rule          | error_message |
      | HmeO2    | HmeO2   | special_hmeo2 | o2b_err       |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | HmeO2    | -1       |
      | HomeDate | 2012/1/1 |
      | LastO2   | 2012/1/2 |
      | Gest     | 1        |
      | Wght     | 1        |
    Then I should see "o2b_err"

  Scenario: CQV Pass - Special_HmeO2 -  If HmeO2 is -1 and (Gest must be <32 or Wght must be <1500) and HomeDate must be a date and HomeDate must be the same as LastO2
    Given I have the following cross question validations
      | question | related | rule          | error_message |
      | HmeO2    | HmeO2   | special_hmeo2 | o2b_err       |

    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | HmeO2    | -1       |
      | HomeDate | 2012/1/1 |
      | LastO2   | 2012/1/1 |
      | Gest     | 1        |
      | Wght     | 1        |
    Then I should not see "o2b_err"


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

  Scenario: CQV Fail - set_gest_wght_implies_set - out of range (low)
    Given I have the following cross question validations
      | question | related | rule                      | error_message                   | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | set_gest_wght_implies_set | Err - set_gest_wght_implies_set | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 0        |
      | USd6wk   | 2012/1/1 |
      | DOB      | 2012/1/2 |
      | Wght     | 1499     |
      | Gest     | 31       |
    Then I should see "Err - set_gest_wght_implies_set"

  Scenario: CQV Fail - set_gest_wght_implies_set - out of range (high)
    Given I have the following cross question validations
      | question | related | rule                      | error_message                   | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | set_gest_wght_implies_set | Err - set_gest_wght_implies_set | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 0         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1499      |
      | Gest     | 31        |
    Then I should see "Err - set_gest_wght_implies_set"

  Scenario: CQV Pass - set_gest_wght_implies_set - out of range but Num Q1 not in range
    Given I have the following cross question validations
      | question | related | rule                      | error_message                   | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | set_gest_wght_implies_set | Err - set_gest_wght_implies_set | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 5         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1499      |
      | Gest     | 31        |
    Then I should not see "Err - set_gest_wght_implies_set"

  Scenario: CQV Pass - set_gest_wght_implies_set - out of range, Num Q1 in range but wght/gest don't meet conds
    Given I have the following cross question validations
      | question | related | rule                      | error_message                   | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | set_gest_wght_implies_set | Err - set_gest_wght_implies_set | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 4         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1600      |
      | Gest     | 33        |
    Then I should not see "Err - set_gest_wght_implies_set"

  Scenario: CQV Pass - set_gest_wght_implies_set - everything meets conds
    Given I have the following cross question validations
      | question | related | rule                      | error_message                   | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | set_gest_wght_implies_set | Err - set_gest_wght_implies_set | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 4        |
      | USd6wk   | 2012/1/1 |
      | DOB      | 2012/2/1 |
      | Wght     | 1500     |
      | Gest     | 32       |
    Then I should not see "Err - set_gest_wght_implies_set"


#####################

  Scenario: CQV Fail - special_usd6wk_dob_weeks - out of range (low)
    Given I have the following cross question validations
      | question | related | rule                     | error_message                  | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_dob_weeks | Err - special_usd6wk_dob_weeks | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 0        |
      | USd6wk   | 2012/1/1 |
      | DOB      | 2012/1/2 |
      | Wght     | 1499     |
      | Gest     | 31       |
    Then I should see "Err - special_usd6wk_dob_weeks"

  Scenario: CQV Fail - special_usd6wk_dob_weeks - out of range (high)
    Given I have the following cross question validations
      | question | related | rule                     | error_message                  | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_dob_weeks | Err - special_usd6wk_dob_weeks | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 0         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1499      |
      | Gest     | 31        |
    Then I should see "Err - special_usd6wk_dob_weeks"

  Scenario: CQV Pass - special_usd6wk_dob_weeks - out of range but Num Q1 not in range
    Given I have the following cross question validations
      | question | related | rule                     | error_message                  | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_dob_weeks | Err - special_usd6wk_dob_weeks | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 5         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1499      |
      | Gest     | 31        |
    Then I should not see "Err - special_usd6wk_dob_weeks"

  Scenario: CQV Pass - special_usd6wk_dob_weeks - out of range, Num Q1 in range but wght/gest don't meet conds
    Given I have the following cross question validations
      | question | related | rule                     | error_message                  | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_dob_weeks | Err - special_usd6wk_dob_weeks | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Num Q1   | 4         |
      | USd6wk   | 2012/1/1  |
      | DOB      | 2012/12/1 |
      | Wght     | 1600      |
      | Gest     | 33        |
    Then I should not see "Err - special_usd6wk_dob_weeks"

  Scenario: CQV Pass - special_usd6wk_dob_weeks - everything meets conds
    Given I have the following cross question validations
      | question | related | rule                     | error_message                  | set_operator | set   | conditional_set_operator | conditional_set |
      | USd6wk   | Num Q1  | special_usd6wk_dob_weeks | Err - special_usd6wk_dob_weeks | range        | [4,8] | range                    | [0,4]           |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 4        |
      | USd6wk   | 2012/1/1 |
      | DOB      | 2012/2/1 |
      | Wght     | 1500     |
      | Gest     | 32       |
    Then I should not see "Err - special_usd6wk_dob_weeks"


#####################
# set_present_implies_present
#####################


  Scenario: CQV Fail - set_present_implies_present - conditions met, blank
  # If IVH is 1-4 and USd6wk is a date, Cysts must be between 0 and 4
    Given I have the following cross question validations
      | question | related_question_list | rule                        | error_message                     | set_operator | set   |
      | Num Q1   | USd6wk, Num Q2        | set_present_implies_present | Err - set_present_implies_present | range        | [1,4] |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 1        |
      | USd6wk   | 2012/1/1 |
    Then I should see "Err - set_present_implies_present"

  Scenario: CQV Pass - set_present_implies_present - conditions met, present
  # If IVH is 1-4 and USd6wk is a date, Cysts must be between 0 and 4
    Given I have the following cross question validations
      | question | related_question_list | rule                        | error_message                     | set_operator | set   |
      | Num Q1   | USd6wk, Num Q2        | set_present_implies_present | Err - set_present_implies_present | range        | [1,4] |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 4        |
      | Num Q2   | 1        |
      | USd6wk   | 2012/1/1 |
    Then I should not see "Err - set_present_implies_present"

  Scenario: CQV Pass - set_present_implies_present - conditions not met (first blank), blank
  # If IVH is 1-4 and USd6wk is a date, Cysts must be between 0 and 4
    Given I have the following cross question validations
      | question | related_question_list | rule                        | error_message                     | set_operator | set   |
      | Num Q1   | USd6wk, Num Q2        | set_present_implies_present | Err - set_present_implies_present | range        | [1,4] |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | USd6wk   | 2012/1/1 |
    Then I should not see "Err - set_present_implies_present"

  Scenario: CQV Pass - set_present_implies_present - conditions not met (first out of range), blank
  # If IVH is 1-4 and USd6wk is a date, Cysts must be between 0 and 4
    Given I have the following cross question validations
      | question | related_question_list | rule                        | error_message                     | set_operator | set   |
      | Num Q1   | USd6wk, Num Q2        | set_present_implies_present | Err - set_present_implies_present | range        | [1,4] |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Num Q1   | 5        |
      | USd6wk   | 2012/1/1 |
    Then I should not see "Err - set_present_implies_present"

  Scenario: CQV Pass - set_present_implies_present - conditions not met (second blank), blank
  # If IVH is 1-4 and USd6wk is a date, Cysts must be between 0 and 4
    Given I have the following cross question validations
      | question | related_question_list | rule                        | error_message                     | set_operator | set   |
      | Num Q1   | USd6wk, Num Q2        | set_present_implies_present | Err - set_present_implies_present | range        | [1,4] |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | 1      |
    Then I should not see "Err - set_present_implies_present"


###################
#  comparison_const_days
###################


  Scenario: CQV Fail - comparison_const_days - out of range
  # days between Date_Linf1 and Date_Linf2 >14
    Given I have the following cross question validations
      | question | related_question_list | rule                  | error_message               | operator | constant |
      | Num Q2   | Num Q1, USd6wk        | comparison_const_days | Err - comparison_const_days | >        | 14       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/1/1 |
      | Date Q2  | 2012/1/2 |
    Then I should not see "Err - comparison_const_days"

  Scenario: CQV Fail - comparison_const_days - out of range (switched order)
  # days between Date_Linf1 and Date_Linf2 >14
    Given I have the following cross question validations
      | question | related_question_list | rule                  | error_message               | operator | constant |
      | Num Q2   | Num Q1, USd6wk        | comparison_const_days | Err - comparison_const_days | >        | 14       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/1/2 |
      | Date Q2  | 2012/1/1 |
    Then I should not see "Err - comparison_const_days"

  Scenario: CQV Pass - comparison_const_days - in range
  # days between Date_Linf1 and Date_Linf2 >14
    Given I have the following cross question validations
      | question | related_question_list | rule                  | error_message               | operator | constant |
      | Num Q2   | Num Q1, USd6wk        | comparison_const_days | Err - comparison_const_days | >        | 14       |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/1/1 |
    Then I should not see "Err - comparison_const_days"
