@javascript
Feature: Dynamic Help
  In order to answer the questions accurately
  As a data provider
  I want to access help

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question  | question_type | description  | guide_for_use | data_domain    |
      | Text Q    | Text          | desc_text    | guide_text    | text_domain    |
      | Date Q    | Date          | desc_date    | guide_date    | date_domain    |
      | Time Q    | Time          | desc_time    | guide_time    | time_domain    |
      | Choice Q  | Choice        | desc_choice  | guide_choice  | choice_domain  |
      | Decimal Q | Decimal       | desc_decimal | guide_decimal | decimal_domain |
      | Integer Q | Integer       | desc_integer | guide_integer | integer_domain |
    And question "Choice Q" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page

  Scenario Outline: Viewing the help text for a question
    When I focus on question "<question>"
    Then I should see the sidebar help for "<question>"
  Examples:
    | question  |
    | Text Q    |
    | Integer Q |
    | Decimal Q |
    | Choice Q  |
    | Date Q    |
    | Time Q    |

  Scenario Outline: Viewing and hiding the help text for a question
    When I focus on question "<question>"
    Then I focus on question "<question_2>"
    Then I should see the sidebar help for "<question_2>"
    And I should not see the sidebar help for "<question>"
  Examples:
    | question  | question_2 |
    | Text Q    | Integer Q  |
    | Integer Q | Decimal Q  |
    | Decimal Q | Choice Q   |
    | Choice Q  | Text Q     |
    | Date Q    | Time Q     |
    | Time Q    | Date Q     |

  Scenario Outline: Viewing tooltips
    When I hover on question label for "<question>"
    Then I should see the help tooltip for "<question>"
  Examples:
    | question  |
    | Text Q    |
    | Integer Q |
    | Decimal Q |
    | Choice Q  |
    | Date Q    |
    | Time Q    |
