Feature: Single-Choice Questions
  In order to enter data
  As a data provider
  I want to save answers to single-choice questions

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question  | question_type |
      | Choice Q1 | Choice        |
      | Choice Q2 | Choice        |
    And question "Choice Q1" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And question "Choice Q2" has question options
      | option_value | label | hint_text | option_order |
      | 99           | Dunno |           | 3            |
      | 0            | Cat   |           | 0            |
      | 2            | Dog   |           | 2            |
      | 1            | Fish  |           | 1            |

  Scenario: Initially displayed with nothing selected, selections are saved
    Given I am ready to enter responses as data.provider@intersect.org.au
    Then I should see choice question "Choice Q1" with options
      | label      | hint         | checked |
      | (0) Yes    | this is true | false   |
      | (1) No     | not true     | false   |
      | (99) Dunno |              | false   |
    And I should see choice question "Choice Q2" with options
      | label      | hint | checked |
      | (0) Cat    |      | false   |
      | (1) Fish   |      | false   |
      | (2) Dog    |      | false   |
      | (99) Dunno |      | false   |
    When I answer as follows
      | question  | answer |
      | Choice Q1 | (1) No |
    And I press "Save page"
    Then I should see choice question "Choice Q1" with options
      | label      | hint         | checked |
      | (0) Yes    | this is true | false   |
      | (1) No     | not true     | true    |
      | (99) Dunno |              | false   |
    And the answer to "Choice Q1" should be "1"
    And I should see choice question "Choice Q2" with options
      | label      | hint | checked |
      | (0) Cat    |      | false   |
      | (1) Fish   |      | false   |
      | (2) Dog    |      | false   |
      | (99) Dunno |      | false   |
