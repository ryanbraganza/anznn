@javascript
Feature: Show warnings on survey pages
  In order to fill in the survey correctly and quickly
  As a data provider
  I want to see warning info when I've entered something incorrectly

  Background:
    Given I have the usual roles
    And I have a user "data.provider@intersect.org.au" with role "Data Provider"
    And I have a survey with name "MySurvey"
    And "MySurvey" has sections
      | name | order |
      | Sec1 | 0     |
      | Sec2 | 1     |
      | Sec3 | 2     |
    And "MySurvey" has questions
      | question        | question_type | section | mandatory |
      | Sect1 QText1    | Text          | 0       | true      |
      | Sect1 QText2    | Text          | 0       | true      |
      | Sect1 QInteger  | Integer       | 0       | true      |
      | Sect1 QDecimal  | Decimal       | 0       | true      |
      | Sect1 QDate     | Date          | 0       | true      |
      | Sect1 QTime     | Time          | 0       | true      |
      | Sect1 QChoice   | Choice        | 0       | true      |
      | Sect1 QOptional | Text          | 0       | false     |
      | Sect2 Q1        | Text          | 1       | true      |
      | Sect2 Q2        | Integer       | 1       | false     |
      | Sect3 Q1        | Text          | 2       | true      |
      | Sect3 Q2        | Integer       | 2       | false     |

  Scenario: As I navigate around without entering anything I don't get any warnings
    Given I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    Then I should see no warnings
    When I follow "Sec2"
    Then I should see no warnings
    When I follow "Sec3"
    Then I should see no warnings
    When I follow "Sec2"
    Then I should see no warnings
    When I follow "Sec1"
    Then I should see no warnings

  Scenario: As soon as I've answered a question in a section, I start seeing required field errors on that section
    Given I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer "Sect1 QText2" with "123"
    And I follow "Sec2"
    And I follow "Sec1"
    Then I should see warning "This question is mandatory" for question "Sect1 QText1"
    Then I should see warning "This question is mandatory" for question "Sect1 QInteger"
    Then I should see warning "This question is mandatory" for question "Sect1 QDecimal"
    Then I should see warning "This question is mandatory" for question "Sect1 QDate"
    Then I should see warning "This question is mandatory" for question "Sect1 QTime"
    Then I should see warning "This question is mandatory" for question "Sect1 QChoice"
    And "Sect1 QOptional" should have no warning
    When I follow "Sec2"
    Then I should see no warnings

  Scenario: Once I've answered, the required field error goes away
    Given I am logged in as "data.provider@intersect.org.au"
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey
    And I am on the edit first response page
    When I answer "Sect1 QText2" with "123"
    And I press "Save page"
    Then "Sect1 QText2" should have no warning
    When I answer as follows
      | question       | answer     |
      | Sect1 QText1   | txt        |
      | Sect1 QInteger | 1          |
      | Sect1 QDecimal | 1          |
      | Sect1 QDate    | 2011/12/12 |
      | Sect1 QTime    | 10:53      |
      | Sect1 QChoice  | (A) Apple  |
    And I press "Save page"
    Then I should see no warnings
