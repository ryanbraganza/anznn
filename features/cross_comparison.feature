Feature: Cross Question Comparison Validations
  In order to ensure data is correct
  As a system owner
  I want answers to be compared by value to other questions

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question   | question_type |
      | Date Q1    | Date          |
      | Date Q2    | Date          |
      | Time Q1    | Time          |
      | Time Q2    | Time          |
      | Integer Q1 | Integer       |
      | Integer Q2 | Integer       |
      | Decimal Q1 | Decimal       |
      | Decimal Q2 | Decimal       |

  Scenario: CQV Pass - Decimal
    Given I have the following cross question validations
      | question   | related    | rule       | operator | error_message        |
      | Decimal Q1 | Decimal Q2 | comparison | ==       | decimal should be eq |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question   | answer |
      | Decimal Q1 | 12.5   |
      | Decimal Q2 | 12.5   |
    And I should not see "decimal should be eq"

  Scenario: CQV Pass - Integer
    Given I have the following cross question validations
      | question   | related    | rule       | operator | error_message        |
      | Integer Q1 | Integer Q2 | comparison | ==       | Integer should be eq |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question   | answer |
      | Integer Q1 | 12     |
      | Integer Q2 | 12     |
    And I should not see "Integer should be eq"

  Scenario: CQV Pass - Time
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message     |
      | Time Q1  | Time Q2 | comparison | ==       | time should be eq |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Time Q1  | 12:30  |
      | Time Q2  | 12:30  |
    And I should not see "time should be eq"

  Scenario: CQV Pass - Date
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message      |
      | Date Q1  | Date Q2 | comparison | ==       | date should be gte |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/1 |
    And I should not see "date should be gte"

  Scenario: CQV Failure - date gte
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message      |
      | Date Q1  | Date Q2 | comparison | >=       | date should be gte |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be gte"

  Scenario: CQV Failure - date lte
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message      |
      | Date Q1  | Date Q2 | comparison | <=       | date should be lte |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/3 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be lte"

  Scenario: CQV Failure - date lt
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message     |
      | Date Q1  | Date Q2 | comparison | <        | date should be lt |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/3 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be lt"

  Scenario: CQV Failure - date gt
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message     |
      | Date Q1  | Date Q2 | comparison | >        | date should be gt |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be gt"

  Scenario: CQV Failure - date eq
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message     |
      | Date Q1  | Date Q2 | comparison | ==       | date should be eq |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be eq"

  Scenario: CQV Failure - date ne
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message            |
      | Date Q1  | Date Q2 | comparison | !=       | date should not be eq |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/1 |
    And I should see "date should not be eq"

  Scenario: CQV Failure - date lte with offset
    Given I have the following cross question validations
      | question | related | rule       | operator | constant | error_message                  |
      | Date Q1  | Date Q2 | comparison | <=       | 1        | date should be not be lte Q2+1 |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/3 |
      | Date Q2  | 2012/2/1 |
    And I should see "date should be not be lte Q2+1"

  Scenario: multiple error messages
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message            |
      | Date Q1  | Date Q2 | comparison | >        | date should be gt        |
      | Date Q1  | Date Q2 | comparison | >        | date should really be gt |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be gt"
    And I should see "date should really be gt"

  Scenario: no infinite loop
    Given I have the following cross question validations
      | question | related | rule       | operator | error_message     |
      | Date Q1  | Date Q2 | comparison | >        | date should be gt |
      | Date Q2  | Date Q1 | comparison | <        | date should be gt |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I answer as follows
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And press "Save page"
  # Then I should not get a "stack level too deep" error
    And I should be on the edit first response page
