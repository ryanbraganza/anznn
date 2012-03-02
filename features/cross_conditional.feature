Feature: Cross Question Conditional Validations
  In order to ensure data is correct
  As a system owner
  I want the dates of answers to follow particular rules

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question | question_type |
      | Num Q1   | Integer       |
      | Num Q2   | Integer       |
      | Date Q1  | Date          |

  @wip
  Scenario: Date Implies Const, eg If Qx is a date then This must be -1 [13 B, Hmegavage]
    Given I have the following cross question validations
      | question | related | rule             | operator | constant | error_message                                |
      | Num Q1   | Date Q1 | date_implies_const |          | -1       | Date entered in Date Q1, this needs to be -1 |

    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer as follows
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Num Q1   | 0        |
    And press "Save page"
    Then I should see the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Num Q1   | 0        |
    And I should see "Date entered in Date Q1, this needs to be -1"

  @wip
  Scenario: Constant Implies Constant, eg If Qx > 0 then This must not be 0 [3A Birth Order]
    Given I have the following cross question validations
      | question | related | rule                | conditional_operator | conditional_constant | operator | constant | error_message                 |
      | Num Q1   | Num Q2  | const_implies_const | >                    | 0                    | !=       | 0        | NumQ2 > 0, so this can't be 0 |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer as follows
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 5      |
    And press "Save page"
    Then I should see the following answers
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 5      |
    And I should see "NumQ2 > 0, so this can't be 0"

  @wip
  Scenario: Constant Implies Set, eg If Qx > 0 then This must be one of <set> [17 B17c Retmaturity]
    Given I have the following cross question validations
      | question | related | rule                | conditional_operator | conditional_constant | operator | constant | error_message                 |
      | Num Q1   | Num Q2  | const_implies_const | >                    | 0                    | !=       | 0        | NumQ2 > 0, so this can't be 0 |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer as follows
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 5      |
    And press "Save page"
    Then I should see the following answers
      | question | answer |
      | Num Q1   | 0      |
      | Num Q2   | 5      |
    And I should see "NumQ2 > 0, so this can't be 0"

