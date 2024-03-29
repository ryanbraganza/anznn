Feature: Cross Question Blank-Unless Validations
  In order to ensure data is correct
  As a system owner
  I want answers to be conditionally validated based on the answers to other questions

#    Complex Blank Unless:
#      days(DOB to HomeDate||DiedDate) >= 60. (this is the only question that uses days()) 15 B DateImmun
#        Expressed as three rules: rule 1 OR 2; Bl_un days(DOB to HomeDate)>=60; Bl_un days(DOB to DiedDate) >=60.
#        The Bl_un days() needs to be implemented


  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question | question_type |
      | Num Q1   | Integer       |
      | Num Q2   | Integer       |
      | DOB Qn   | Date          |
      | Date Q1  | Date          |
      | Date Q2  | Date          |


  Scenario: CQV Pass - Blank Unless Present - This Qn must be blank unless other question is present (testing with dates)
    Given I have the following cross question validations
      | question | related | rule                 | error_message                  |
      | Date Q1  | Date Q2 | blank_unless_present | q2 was blank, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q2  | 2012/1/1 |
      | Date Q1  | 2012/1/1 |
    Then I should not see "q2 was blank, q1 must be blank"

  Scenario: CQV Pass - Blank Unless Present - This Qn must be blank unless other question is present (testing with dates) - invalid date
    Given I have the following cross question validations
      | question | related | rule                 | error_message                  |
      | Date Q1  | Date Q2 | blank_unless_present | q2 was blank, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer    |
      | Date Q2  | 2012/2/31 |
      | Date Q1  | 2012/1/1  |
    Then I should not see "q2 was blank, q1 must be blank"

  Scenario: CQV Failure - Blank Unless Present - This Qn must be blank unless other question is present (testing with dates) - blank date
    Given I have the following cross question validations
      | question | related | rule                 | error_message                  |
      | Date Q1  | Date Q2 | blank_unless_present | q2 was blank, q1 must be blank |
    And I am ready to enter responses as data.provider@intersect.org.au
    When I store the following answers
      | question | answer   |
      | Date Q1  | 2012/1/1 |
    Then I should see "q2 was blank, q1 must be blank"

