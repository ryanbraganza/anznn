Feature: Show hints to user on survey page
  In order to fill in the survey correctly and quickly
  As a data provider
  I want to see help text about the expected format of the response

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question  | question_type | number_min | number_max | number_unknown | string_min | string_max |
      | Text Q    | Text          |            |            |                | 5          | 10         |
      | Integer Q | Integer       | -100       | 500        |                |            |            |
      | Decimal Q | Decimal       |            | 10         | 99             |            |            |

  Scenario: Viewing the help text
    Given I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    Then I should see help text "Text between 5 and 10 characters" for question "Text Q"
    Then I should see help text "Number between -100 and 500" for question "Integer Q"
    Then I should see help text "Decimal number a maximum of 10 or 99 for unknown" for question "Decimal Q"
