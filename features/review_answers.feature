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
      | question   | question_type | section | mandatory | string_min | string_max |
      | Text Qn    | Text          | 0       | true      | 8          | 8          |
      | Decimal Qn | Decimal       | 0       | false     |            |            |
      | Integer Qn | Integer       | 0       | true      |            |            |
      | Date Qn    | Date          | 1       | true      |            |            |
      | Time Qn    | Time          | 1       | true      |            |            |
      | Choice Qn  | Choice        | 1       | false     |            |            |
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
      | Text Qn    | Not answered\nThis question is mandatory |
      | Decimal Qn | Not answered                             |
      | Integer Qn | Not answered\nThis question is mandatory |
    And I should see answers for section "SectionTwo"
      | Date Qn   | Not answered\nThis question is mandatory |
      | Time Qn   | Not answered\nThis question is mandatory |
      | Choice Qn | Not answered                             |

  @javascript
  Scenario: Shows answers in an appropriate format for those that are answered
    Given I am on the response page for ABCDEF
    And I answer as follows
      | question   | answer   |
      | Text Qn    | abcdefgh |
      | Decimal Qn | 1.23     |
      | Integer Qn | 22       |
    And I follow "SectionTwo"
    And I answer as follows
      | question  | answer     |
      | Date Qn   | 2011/12/25 |
      | Time Qn   | 18:56      |
      | Choice Qn | (0) Yes    |
    And I follow "Summary"
    And I follow "Review Answers"
    Then I should see answers for section "SectionOne"
      | Text Qn    | abcdefgh |
      | Decimal Qn | 1.23     |
      | Integer Qn | 22       |
    And I should see answers for section "SectionTwo"
      | Date Qn   | 25/12/2011 |
      | Time Qn   | 18:56      |
      | Choice Qn | (0) Yes    |

  @javascript
  Scenario: warnings/errors are shown beneath answers - required/range/format errors
    Given I am on the response page for ABCDEF
    And I answer as follows
      | question   | answer |
      | Decimal Qn | abc    |
      | Text Qn    | abcd   |
    And I follow "Summary"
    And I follow "Review Answers"
    Then I should see answers for section "SectionOne"
      | Text Qn    | abcd\nAnswer should be 8 characters                   |
      | Decimal Qn | Answer is the wrong format (Expected a decimal value) |
      | Integer Qn | Not answered\nThis question is mandatory              |

  @javascript
  Scenario: Bad/partially filled dates and times are not shown, just error is shown instead
    Given "MySurvey" has questions
      | question  | question_type | section | mandatory | string_min | string_max |
      | Date Qn 2 | Date          | 1       | true      |            |            |
      | Time Qn 2 | Time          | 1       | true      |            |            |
      | Date Qn 3 | Date          | 1       | true      |            |            |
      | Time Qn 3 | Time          | 1       | true      |            |            |
    Given I am on the response page for ABCDEF
    And I follow "SectionTwo"
  # some are unanswered, some are invalid, some are valid
    And I answer as follows
      | question  | answer      |
      | Date Qn 2 | 2011/12/Day |
      | Time Qn 2 | 14:Minute   |
      | Date Qn 3 | 2011/12/25  |
      | Time Qn 3 | 14:43       |
    And I follow "Summary"
    And I follow "Review Answers"
    Then I should see answers for section "SectionTwo"
      | Date Qn   | Not answered\nThis question is mandatory             |
      | Time Qn   | Not answered\nThis question is mandatory             |
      | Choice Qn | Not answered                                         |
      | Date Qn 2 | Answer is incomplete (one or more fields left blank) |
      | Time Qn 2 | Answer is incomplete (a field was left blank)        |
      | Date Qn 3 | 25/12/2011                                           |
      | Time Qn 3 | 14:43                                                |
