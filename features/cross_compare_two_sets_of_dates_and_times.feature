Feature: Cross Question Validations - compare 2 pairs of date+time
  In order to ensure data is correct
  As a system owner
  I want answers to be validated by comparing 2 pairs of date+time

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
    Given I have the following cross question validations
      | question | related | related_question_list              | rule                        | operator | constant | error_message                      |
      | Date Q1  |         | Date Q1, Time Q1, Date Q2, Time Q2 | multi_compare_datetime_quad | <=       | 0        | Date1+Time1 must be <= Date2+Time2 |
    And I am ready to enter responses as data.provider@intersect.org.au

  Scenario: Failure - all are answered but don't meet comparison condition
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/3 |
      | Time Q1  | 01:23    |
      | Date Q2  | 2012/2/2 |
      | Time Q2  | 11:23    |
    Then I should see "Date1+Time1 must be <= Date2+Time2"

  Scenario: Success - all are answered and do meet comparison condition
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/2 |
      | Time Q1  | 01:23    |
      | Date Q2  | 2012/2/2 |
      | Time Q2  | 11:23    |
    Then I should not see "Date1+Time1 must be <= Date2+Time2"

  Scenario: Success - all are answered and do meet comparison condition (exactly equals)
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/2 |
      | Time Q1  | 11:23    |
      | Date Q2  | 2012/2/2 |
      | Time Q2  | 11:23    |
    Then I should not see "Date1+Time1 must be <= Date2+Time2"

  Scenario: Success - the question the rule is applied to is not answered
    When I store the following answers
      | question | answer   |
      | Time Q1  | 11:23    |
      | Date Q2  | 2012/2/2 |
      | Time Q2  | 11:23    |
    Then I should not see "Date1+Time1 must be <= Date2+Time2"

  Scenario: Success - some of the related questions are not answered
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/2 |
      | Time Q1  | 11:23    |
    Then I should not see "Date1+Time1 must be <= Date2+Time2"

