Feature: Errors and Warnings
  In order to know what to fix
  As a data provider
  I want to see warnings and errors

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"
    And I have a survey with name "survey" and questions
      | section | question   | question_type | number_min | number_max | mandatory |
      | 1       | Text Qn    | Text          |            |            | true      |
      | 2       | Decimal Qn | Decimal       | 2          | 3          | true      |
      | 3       | Integer Qn | Integer       | 4          | 6          | true      |
      | 4       | Date Qn    | Date          |            |            | true      |
      | 5       | Time Qn    | Time          |            |            | true      |
      | 6       | Choice Qn  | Choice        |            |            | true      |
    And question "Choice Qn" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And "data.provider@intersect.org.au" created a response to the "survey" survey

  Scenario: Not started yet is considered to be incomplete
    When I am on the homepage
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  | Status      |
      | babycode123 | survey      | Fred Bloggs | Incomplete |

  Scenario: Incomplete
    When I am on the edit section 1 page
    And I answer as follows
      | question   | answer     |
      | Text Qn    | Text       |
    And I press "Save page"
    When I am on the homepage
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  | Status     |
      | babycode123 | survey      | Fred Bloggs | Incomplete |

  Scenario: Complete with warnings
    When I am on the edit section 1 page
    And I answer as follows
      | question   | answer     |
      | Text Qn    | Text       |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Decimal Qn | 1.5        |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Integer Qn | 7          |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Date Qn    | 2011/12/25 |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Time Qn    | 14:52      |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Choice Qn  | (1) No     |
    And I press "Save page"

    When I am on the homepage
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  | Status                 |
      | babycode123 | survey      | Fred Bloggs | Complete with warnings |

  Scenario: Complete
    When I am on the edit section 1 page
    And I answer as follows
      | question   | answer     |
      | Text Qn    | Text       |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Decimal Qn | 2          |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Integer Qn | 6          |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Date Qn    | 2011/12/25 |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Time Qn    | 14:52      |
    And I press "Save and go to next section"
    And I answer as follows
      | question   | answer     |
      | Choice Qn  | (1) No     |
    And I press "Save page"

    When I am on the homepage
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  | Status   |
      | babycode123 | survey      | Fred Bloggs | Complete |
