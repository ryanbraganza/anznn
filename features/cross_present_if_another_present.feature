Feature: Cross Question Present-If-Present Validations
  In order to ensure data is correct
  As a system owner
  I want answers validated such that Question B must be answered if Question A is answered

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
    And I have the following cross question validations
      | question | related | rule                    | error_message          |
      | Date Q1  | Time Q2 | present_implies_present | time should be present |
    And I am ready to enter responses as data.provider@intersect.org.au

  Scenario: If one answer is present, another must also be present (date and time) - pass (both answered)
    When I store the following answers
      | question | answer     |
      | Date Q1  | 2009/12/23 |
      | Time Q2  | 11:52      |
    Then I should not see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - pass (first one not answered)
    When I store the following answers
      | question | answer |
      | Time Q2  | 11:52  |
    Then I should not see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - pass (neither answered)
    When I store the following answers
      | question   | answer |
      | Integer Q1 | 3      |
    Then I should not see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - fail (second question unanswered)
    When I store the following answers
      | question | answer     |
      | Date Q1  | 2009/12/23 |
    Then I should see "time should be present"

  Scenario: If one answer is present, another must also be present (date and time) - fail (invalid second answer)
    When I store the following answers
      | question | answer     |
      | Date Q1  | 2009/12/23 |
      | Time Q2  | 11:        |
    Then I should see "time should be present"

