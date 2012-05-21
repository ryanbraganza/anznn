Feature: Cross Question Blank-If-Const Validations
  In order to ensure data is correct
  As a system owner
  I want answers to validate such that a question must be blank if another has a certain value
  E.g. If Died_ is 0, DiedDate must be blank (rule is on DiedDate)


  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question  | question_type |
      | Died_     | Choice        |
      | DiedDate  | Date          |
      | Unrelated | Integer       |
    And question "Died_" has question options
      | option_value | label |
      | -1           | Yes   |
      | 0            | No    |
      | 99           | Dunno |
    And I have the following cross question validations
      | question | related | rule           | conditional_operator | conditional_constant | error_message                         |
      | DiedDate | Died_   | blank_if_const | ==                   | 0                    | If Died_ is 0, DiedDate must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au

  Scenario: Pass when neither answered
    When I store the following answers
      | question  | answer |
      | Unrelated | 2      |
    Then I should not see "If Died_ is 0, DiedDate must be blank"

  Scenario: Pass when DiedDate answered and Died_ is not 0
    When I store the following answers
      | question | answer     |
      | DiedDate | 2010/12/25 |
      | Died_    | (-1) Yes   |
    Then I should not see "If Died_ is 0, DiedDate must be blank"

  Scenario: Fail when DiedDate answered and Died_is 0
    When I store the following answers
      | question | answer     |
      | DiedDate | 2010/12/25 |
      | Died_    | (0) No     |
    Then I should see "If Died_ is 0, DiedDate must be blank"

  Scenario: Pass when DiedDate answered and Died_not answered
    When I store the following answers
      | question | answer     |
      | DiedDate | 2010/12/25 |
    Then I should not see "If Died_ is 0, DiedDate must be blank"

  Scenario: Pass when DiedDate not answered and Died_is 0
    When I store the following answers
      | question | answer     |
      | Died_    | (0) No     |
    Then I should not see "If Died_ is 0, DiedDate must be blank"
