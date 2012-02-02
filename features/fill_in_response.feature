Feature: Fill in a survey response
  In order to enter data
  As a data provider
  I want my answers to a survey to be stored correctly

  Background:
    And I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"
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
      | question   | answer     |
      | Text Qn    | Text       |
      | Decimal Qn | 1.5        |
      | Integer Qn | 1          |
      | Date Qn    | 2011/12/25 |
      | Time Qn    | 14:52      |
      | Choice Qn  | (1) No     |
    And press "Save page"
    Then I should see "Your answers have been saved"
    And I should see the following answers
      | question   | answer     |
      | Text Qn    | Text       |
      | Decimal Qn | 1.5        |
      | Integer Qn | 1          |
      | Date Qn    | 2011/12/25 |
      | Time Qn    | 14:52      |
      | Choice Qn  | (1) No     |
    And I should have 6 answers

  Scenario: Empty answers should not be saved to a record
    Given I am on the edit first response page
    And I press "Save page"
    Then I should have no answers

  Scenario: Blanking out previously entered responses should delete any existing answer
    Given I am on the edit first response page
    When I answer as follows
      | question   | answer     |
      | Text Qn    | Text       |
      | Decimal Qn | 1.5        |
      | Integer Qn | 1          |
      | Date Qn    | 2011/12/25 |
      | Time Qn    | 14:52      |
      | Choice Qn  | (1) No     |
    And press "Save page"
    Then I should have 6 answers
    When I answer as follows
      | question   | answer |
      | Text Qn    |        |
      | Decimal Qn |        |
      | Integer Qn |        |
      | Date Qn    |        |
      | Time Qn    |        |
    And I press "Save page"
  # its not possible to blank out choices
    Then I should have 1 answer