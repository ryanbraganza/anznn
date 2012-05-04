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
      | Date Q1  | Date          |
      | Time Q1  | Time          |
      | Date Q2  | Date          |
      | Time Q2  | Time          |


  Scenario: CQV Failure - Multiple Questions blah
    Given I have the following cross question validations
      | question | related | related_question_list              | rule                     | operator | constant | error_message                                    |
      | Num Q1   |         | Date Q1, Time Q1, Date Q2, Time Q2 | multi_hours_date_to_date | <=       | 0        | this must be <= Hours (Date+Time1 to Date+Time2) |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Time Q1  | 01:23    |
      | Date Q2  | 2012/2/2 |
      | Time Q2  | 01:23     |
      | Num Q1   | 30       |
    Then I should see "this must be <= Hours (Date+Time1 to Date+Time2)"
