@javascript
Feature: View a summary page for a survey response
  In order to see where I'm up to
  As a data provider
  I want to view a summary page showing my progress through the sections

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider"
    And I have a survey with name "MySurvey"
    And "MySurvey" has sections
      | name | order |
      | Sec1 | 0     |
      | Sec2 | 1     |
      | Sec3 | 2     |
    And "MySurvey" has questions
      | question        | question_type | section | mandatory | number_min |
      | Sect1 QText1    | Text          | 0       | true      |            |
      | Sect1 QText2    | Text          | 0       | true      |            |
      | Sect1 QInteger  | Integer       | 0       | true      | 10         |
      | Sect1 QDecimal  | Decimal       | 0       | true      |            |
      | Sect1 QDate     | Date          | 0       | true      |            |
      | Sect1 QTime     | Time          | 0       | true      |            |
      | Sect1 QChoice   | Choice        | 0       | true      |            |
      | Sect1 QOptional | Text          | 0       | false     |            |
      | Sect2 Q1        | Text          | 1       | true      |            |
      | Sect2 Q2        | Integer       | 1       | false     |            |
      | Sect3 Q1        | Text          | 2       | true      |            |
      | Sect3 Q2        | Integer       | 2       | false     |            |
    And "data.provider@intersect.org.au" created a response to the "MySurvey" survey with babycode "babycode123" and year of registration "2005"

  Scenario: Navigate from summary to section
    Given I am on the edit first response page
    When I follow "Summary"
    Then I should see "MySurvey - Baby Code babycode123 - Year of Registration 2005"
    When I follow "Edit" for section "Sec2"
    Then I should see "Sec2"

  Scenario: Initially everything is "Not Started"
    Given I am on the edit first response page
    When I follow "Summary"
    Then I should see "summary" table with
      | Section | Status      |
      | Sec1    | Not started |
      | Sec2    | Not started |
      | Sec3    | Not started |

  Scenario: Section changes to "Incomplete" once at least one question is answered
    Given I am on the edit first response page
    When I answer "Sect1 QText1" with "123"
    And I follow "Summary"
    Then I should see "summary" table with
      | Section | Status      |
      | Sec1    | Incomplete  |
      | Sec2    | Not started |
      | Sec3    | Not started |

  Scenario: Section is complete with warnings when range warnings are present (and all questions are answered)
    Given I am on the edit first response page
    When I answer as follows
      | question       | answer     |
      | Sect1 QText1   | abc        |
      | Sect1 QText2   | def        |
      | Sect1 QInteger | 5          |
      | Sect1 QDecimal | 1          |
      | Sect1 QDate    | 2011/12/31 |
      | Sect1 QTime    | 11:30      |
      | Sect1 QChoice  | (A) Apple  |
    And I follow "Summary"
    Then I should see "summary" table with
      | Section | Status                 |
      | Sec1    | Complete with warnings |
      | Sec2    | Not started            |
      | Sec3    | Not started            |

  Scenario: Section is incomplete when a cross-question validation fails (and all questions are answered)
    Given I have the following cross question validations
      | question    | related     | rule       | operator | error_message        |
      | Sect1 QDate | Sect1 QDate | comparison | >        | This will never pass |
    And I am on the edit first response page
    When I answer as follows
      | question       | answer     |
      | Sect1 QText1   | abc        |
      | Sect1 QText2   | def        |
      | Sect1 QInteger | 5          |
      | Sect1 QDecimal | 1          |
      | Sect1 QDate    | 2011/12/31 |
      | Sect1 QTime    | 11:30      |
      | Sect1 QChoice  | (A) Apple  |
    And I follow "Summary"
    Then I should see "summary" table with
      | Section | Status      |
      | Sec1    | Incomplete  |
      | Sec2    | Not started |
      | Sec3    | Not started |

  Scenario: Section becomes complete when all are answered correctly
    Given I am on the edit first response page
    When I answer as follows
      | question       | answer     |
      | Sect1 QText1   | abc        |
      | Sect1 QText2   | def        |
      | Sect1 QInteger | 11         |
      | Sect1 QDecimal | 1          |
      | Sect1 QDate    | 2011/12/31 |
      | Sect1 QTime    | 11:30      |
      | Sect1 QChoice  | (A) Apple  |
    And I follow "Summary"
    Then I should see "summary" table with
      | Section | Status      |
      | Sec1    | Complete    |
      | Sec2    | Not started |
      | Sec3    | Not started |


