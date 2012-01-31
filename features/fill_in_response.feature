@wip
Feature: Fill in a survey response
  In order to enter data
  As a data provider
  I want my answers to a survey to be stored correctly

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "survey" and questions
      | question   | question_type |
      | Text Qn    | Text          |
      | Decimal Qn | Decimal       |
      | Integer Qn | Integer       |
      | Date Qn    | Date          |
      | Time Qn    | Time          |
      | Choice Qn  | Choice        |
    And question "Choice Qn" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And "data.provider@intersect.org.au" created a response to the "survey" survey

  Scenario: Saving a simple response
    Given I am on the edit first response page
    When I answer as follows
      | question   | answer |
      | Text Qn    | Text   |
      | Decimal Qn | 1.5    |
      | Integer Qn | 1      |
      | Date Qn    | *****  |
      | Time Qn    | ****** |
      | Choice Qn  | (1) No |
    And press "Save page"
    Then I should see "Saved page"
    And I should see the simple questions with my previous answers
