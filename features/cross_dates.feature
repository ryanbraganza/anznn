Feature: Cross Question Date Validations
  In order to ensure data is correct
  As a system owner
  I want the dates of answers to follow particular rules

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question | question_type |
      | Date Q1  | Date          |
      | Date Q2  | Date          |

  @wip
  Scenario: date gte
    Given I have the following cross question validations
      | question | related | rule     | error_message      |
      | Date Q1  | Date Q2 | date_gte | date should be gte |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer as follows
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And press "Save page"
    Then I should see the following answers
      | question | answer   |
      | Date Q1  | 2012/2/1 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be gte"

  Scenario: date lte
    Given I have the following cross question validations
      | question | related | rule     | error_message      |
      | Date Q1  | Date Q2 | date_lte | date should be lte |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer as follows
      | question | answer   |
      | Date Q1  | 2012/2/3 |
      | Date Q2  | 2012/2/2 |
    And press "Save page"
    Then I should see the following answers
      | question | answer   |
      | Date Q1  | 2012/2/3 |
      | Date Q2  | 2012/2/2 |
    And I should see "date should be lte"
