Feature: Cross Question Conditional Validations
  In order to ensure data is correct
  As a system owner
  I want answers to be conditionally validated based the success of one of multiple rules

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question | question_type |
      | Num Q1   | Integer       |
      | Num Q2   | Integer       |
      | Num Q3   | Integer       |

  @wip
  Scenario: CQV Failure - Multiple Questions blah
    Given I have the following cross question validations
      | question | related | related_question_list | rule_label_list | rule_label | primary | rule                  | operator | constant | error_message                                |
      | Num Q1   |         | Num Q2, Num Q3        |                 |            |         | date_implies_constant | ==       | -1       | Date entered in Date Q1, this needs to be -1 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Num Q1   | 0        |
    Then I should see "Date entered in Date Q1, this needs to be -1"
