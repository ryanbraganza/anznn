@javascript
Feature: Fill in a survey response, answering questions marked as "multi"
  In order to enter my data
  As a data provider
  I want to be able to answer questions that accept multiple answers

  Background:
    And I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"
    And I have a survey with name "survey" and questions
      | question  | question_type | multiple | multi_name | group_number | order_within_group |
      | Text Qn   | Text          | false    |            |              |                    |
      | NameSurg1 | Text          | true     | Surgery    | 1            | 1                  |
      | TypeSurg1 | Integer       | true     | Surgery    | 1            | 2                  |
      | NameSurg2 | Text          | true     | Surgery    | 2            | 1                  |
      | TypeSurg2 | Integer       | true     | Surgery    | 2            | 2                  |
      | NameSurg3 | Text          | true     | Surgery    | 3            | 1                  |
      | TypeSurg3 | Integer       | true     | Surgery    | 3            | 2                  |
      | Time Qn   | Time          | false    |            |              |                    |
    And "data.provider@intersect.org.au" created a response to the "survey" survey

  Scenario: Initially only the first group of questions should be shown, with a link to add another
    Given I am on the edit first response page
    Then I should see questions
      | Text Qn   |
      | NameSurg1 |
      | TypeSurg1 |
      | Time Qn   |
    And I should see link "Add another Surgery" within the question area for 'TypeSurg1'

  Scenario: Clicking the add another link should reveal another group of questions and hide the link that was clicked
    Given I am on the edit first response page
    When I follow "Add another Surgery"
    Then I should see questions
      | Text Qn   |
      | NameSurg1 |
      | TypeSurg1 |
      | NameSurg2 |
      | TypeSurg2 |
      | Time Qn   |
    And I should see link "Add another Surgery" within the question area for 'TypeSurg2'
    And I should not see link "Add another Surgery" within the question area for 'TypeSurg1'

  Scenario: Add another link should not show once we get to the last group of questions
    Given I am on the edit first response page
    When I follow "Add another Surgery"
    When I follow "Add another Surgery"
    Then I should not see link "Add another Surgery"
    And I should see questions
      | Text Qn   |
      | NameSurg1 |
      | TypeSurg1 |
      | NameSurg2 |
      | TypeSurg2 |
      | NameSurg3 |
      | TypeSurg3 |
      | Time Qn   |

  Scenario: Returning after answering some should show the right set of groups
    Given I am on the edit first response page
    When I follow "Add another Surgery"
    And I follow "Add another Surgery"
    And I answer as follows
      | question  | answer |
      | NameSurg1 | fred   |
      | TypeSurg2 | 3      |
    And press "Save page"
    Then I should see questions
      | Text Qn   |
      | NameSurg1 |
      | TypeSurg1 |
      | NameSurg2 |
      | TypeSurg2 |
      | Time Qn   |
    When I follow "Add another Surgery"
    And I answer as follows
      | question  | answer |
      | NameSurg1 | fred   |
      | TypeSurg2 |        |
      | TypeSurg3 | 3      |
    And press "Save page"
    Then I should see questions
      | Text Qn   |
      | NameSurg1 |
      | TypeSurg1 |
      | NameSurg2 |
      | TypeSurg2 |
      | NameSurg3 |
      | TypeSurg3 |
      | Time Qn   |
