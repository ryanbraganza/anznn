Feature: Cross Question Conditional Validations
  In order to ensure data is correct
  As a system owner
  I want answers to be conditionally validated based the success of one of multiple rules

#  Processing rules
#    Intersection of multiple rules (||, at least one must pass)
#      If rule 1 OR rule 2 13 A14 PNS
#    Implication with multiple rules
#      If rule 1 passes THEN apply rule 2. failure of rule 1 means rule 2 is skipped and answer is valid 12 A13c, NameSurg2

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question | question_type |
      | Num Q1   | Integer       |
      | Num Q2   | Integer       |
      | Num Q3   | Integer       |
      | Num Q4   | Integer       |
      | Num Q5   | Integer       |
    And I have the following cross question validations
      | question | related | rule_label_list      | rule_label | rule                | operator | error_message                                |
      | Num Q1   |         | any_pass1, any_pass2 |            | multi_rule_any_pass |          | must be equal to either NumQ2 or NumQ3       |
      | Num Q1   | Num Q2  |                      | any_pass1  | comparison          | ==       | Ignored 1                                    |
      | Num Q1   | Num Q3  |                      | any_pass2  | comparison          | ==       | Ignored 2                                    |
      | Num Q4   |         | if_then1, if_then2   |            | multi_rule_if_then  |          | Rule 1 was true, so Rule 2 must also be true |
      | Num Q4   | Num Q2  |                      | if_then1   | comparison          | ==       | Ignored 1                                    |
      | Num Q4   | Num Q3  |                      | if_then2   | comparison          | ==       | Ignored 2                                    |

  Scenario: CQV Failure - Any Pass - Rule ONE and TWO fail
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 1      |
      | Num Q3   | 2      |
    Then I should see "must be equal to either NumQ2 or NumQ3"
    And I should not see "Ignored"

  Scenario: CQV Success - Any Pass - Rule ONE fails, TWO PASSES
    When I store the following answers
      | question | answer |
      | Num Q1   | 1      |
      | Num Q2   | 1      |
      | Num Q3   | 2      |
    Then I should not see "must be equal to either NumQ2 or NumQ3"
    And I should not see "Ignored"

  Scenario: CQV Success - Any Pass - Rule TWO fails, ONE PASSES
    When I store the following answers
      | question | answer |
      | Num Q1   | 2      |
      | Num Q2   | 1      |
      | Num Q3   | 2      |
    Then I should not see "must be equal to either NumQ2 or NumQ3"
    And I should not see "Ignored"

  Scenario: CQV Success - Any Pass - Rule ONE and TWO PASSES
    When I store the following answers
      | question | answer |
      | Num Q1   | 1      |
      | Num Q2   | 1      |
      | Num Q3   | 1      |
    Then I should not see "must be equal to either NumQ2 or NumQ3"
    And I should not see "Ignored"

    ###################
  Scenario: CQV Pass - If Then - Rule ONE fails, TWO isn't processed
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Num Q4   | 0      |
      | Num Q2   | 1      |
      | Num Q3   | 2      |
    Then I should not see "Rule 1 was true, so Rule 2 must also be true"
    And I should not see "Ignored"

  Scenario: CQV Failure - If Then - Rule TWO fails, ONE PASSES
    When I store the following answers
      | question | answer |
      | Num Q4   | 2      |
      | Num Q2   | 1      |
      | Num Q3   | 2      |
    Then I should see "Rule 1 was true, so Rule 2 must also be true"
    And I should not see "Ignored"

  Scenario: CQV Success - If Then - Rule ONE and TWO PASSES
    When I store the following answers
      | question | answer |
      | Num Q4   | 1      |
      | Num Q2   | 1      |
      | Num Q3   | 1      |
    Then I should not see "Rule 1 was true, so Rule 2 must also be true"
    And I should not see "Ignored"
