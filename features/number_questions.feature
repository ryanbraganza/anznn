Feature: Number Questions
  In order to enter data
  As a data provider
  I want to save answers to number questions

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question  | question_type | number_min | number_max | number_unknown |
      | Integer Q | Integer       | -100       | 500        |                |
      | Decimal Q | Decimal       |            | 10         | 99             |

  Scenario: Integers
    Given I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    And I answer as follows
      | question  | answer |
      | Integer Q | 4      |
      | Decimal Q | 5.23   |
    And I press "Save page"
    Then I should see the following answers
      | question  | answer |
      | Integer Q | 4      |
      | Decimal Q | 5.23   |
