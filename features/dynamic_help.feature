@javascript
Feature: Dynamic Help
  In order to answer the questions accurately
  As a data provider
  I want to access help

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey" and questions
      | question   | question_type | description  | guide_for_use |
      | Text Q     | Text          | desc_text    | guide_text    |
      | Date Q     | Date          | desc_date    | guide_date    |
      | Time Q     | Time          | desc_time    | guide_time    |
      | Choice Q   | Choice        | desc_choice  | guide_choice  |
      | Decimal Q  | Decimal       | desc_decimal | guide_decimal |
      | Integer Q  | Integer       | desc_integer | guide_integer |
      | No Guide Q | Integer       | desc_integer |               |
    And question "Choice Q" has question options
      | option_value | label | hint_text    | option_order |
      | 99           | Dunno |              | 2            |
      | 0            | Yes   | this is true | 0            |
      | 1            | No    | not true     | 1            |
    And I am ready to enter responses as data.provider@intersect.org.au

    @wip
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
    | No Guide Q    |

      @wip
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

