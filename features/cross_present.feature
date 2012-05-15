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
      | Choice Q1  | Choice        |
      | Choice Q2  | Choice        |
      | Text Q1    | Text          |
      | Text Q2    | Text          |
    And question "Choice Q1" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And question "Choice Q2" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |

  Scenario: If one answer is present, another must also be present (date and time) - pass (both answered)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          |
      | Date Q1  | Time Q2 | present_implies_present | time should be present |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer     |
      | Date Q1  | 2009/12/23 |
      | Time Q2  | 11:52      |
    Then I should not see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - pass (first one not answered)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          |
      | Date Q1  | Time Q2 | present_implies_present | time should be present |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer |
      | Time Q2  | 11:52  |
    Then I should not see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - pass (neither answered)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          |
      | Date Q1  | Time Q2 | present_implies_present | time should be present |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question   | answer |
      | Integer Q1 | 3      |
    Then I should not see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - fail (second question unanswered)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          |
      | Date Q1  | Time Q2 | present_implies_present | time should be present |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer     |
      | Date Q1  | 2009/12/23 |
    Then I should see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - fail (invalid second answer)
    Given I have the following cross question validations
      | question | related | rule                    | error_message          |
      | Date Q1  | Time Q2 | present_implies_present | time should be present |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer     |
      | Date Q1  | 2009/12/23 |
      | Time Q2  | 11:       |
    Then I should see "time should be present"

