@wip
Feature: Review my answers
  In order to provide accurate data
  As a data provider
  I want to review my answers

  Background:
    And I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"
    And I have a survey with name "MySurvey"
    And "MySurvey" has sections
      | name       | order |
      | SectionOne | 0     |
      | SectionTwo | 1     |
    And "MySurvey" has questions
      | question   | question_type | section |
      | Text Qn    | Text          | 0       |
      | Decimal Qn | Decimal       | 0       |
      | Integer Qn | Integer       | 0       |
      | Date Qn    | Date          | 1       |
      | Time Qn    | Time          | 1       |
      | Choice Qn  | Choice        | 1       |
    And question "Choice Qn" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And I create a response for "MySurvey" with baby code "ABCDEF"

  Scenario: Navigate from home page to review answers page
    Given I am on the home page
    When I follow "Review Answers"
    Then I should be on the review answers page for ABCDEF
    And I should see "MySurvey - Baby Code ABCDEF"

  Scenario: Navigate from summary page to review answers and back again
    Given I am on the home page
    And I follow "View Summary"
    When I follow "Review Answers"
    Then I should be on the review answers page for ABCDEF
    And I should see "MySurvey - Baby Code ABCDEF"
    When I follow "Go To Summary Page"
    Then I should be on the response summary page for ABCDEF

  Scenario: Navigate from reviewing answers to editing answers
    Given I am on the home page
    And I follow "View Summary"
    When I follow "Review Answers"
    And I follow "Edit Answers" for section "SectionOne"
    Then I should see "SectionOne"
    And I should be on the response page for ABCDEF


  Scenario: Shows 'Not answered' for questions that are not answered yet
    Given I am on the review answers page for ABCDEF
    Then I should see answers for section "SectionOne"
      | Text Qn    | Not answered |
      | Decimal Qn | Not answered |
      | Integer Qn | Not answered |
    And I should see answers for section "SectionTwo"
      | Date Qn   | Not answered |
      | Time Qn   | Not answered |
      | Choice Qn | Not answered |

  @javascript
  Scenario: Shows answers in an appropriate format for those that are answered
    Given I am on the response page for ABCDEF
    And I answer as follows
      | question   | answer |
      | Text Qn    | mytext |
      | Decimal Qn | 1.23   |
      | Integer Qn | 22     |
    And I follow "SectionTwo"
    And I answer as follows
      | question  | answer     |
      | Date Qn   | 2011/12/25 |
      | Time Qn   | 18:56      |
      | Choice Qn | (0) Yes    |
    And I follow "Summary"
    And I follow "Review Answers"
    Then I should see answers for section "SectionOne"
      | Text Qn    | mytext |
      | Decimal Qn | 1.23   |
      | Integer Qn | 22     |
    And I should see answers for section "SectionTwo"
      | Date Qn   | 25/12/2011 |
      | Time Qn   | 18:56      |
      | Choice Qn | (0) Yes    |

  Scenario: saved invalid answers are shown as?
    #TODO

  Scenario: warnings are shown as ?
    #TODO