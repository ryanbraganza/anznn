@javascript
Feature: Navigating around the sections of a survey response
  In order to enter data quickly
  As a data provider
  I want to navigate between sections of a survey response

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
      | question | question_type | section |
      | Sect1 Q1 | Text          | 0       |
      | Sect1 Q2 | Integer       | 0       |
      | Sect2 Q1 | Text          | 1       |
      | Sect2 Q2 | Integer       | 1       |
      | Sect3 Q1 | Text          | 2       |
      | Sect3 Q2 | Integer       | 2       |

  Scenario: When I first start a new survey response, the first section is shown
    Given I am logged in as "data.provider@intersect.org.au"
    When I create a response for "MySurvey" with baby code "ABC123"
    Then I should see questions
      | Sect1 Q1 |
      | Sect1 Q2 |

  Scenario: When I click on a section, that section is shown
    Given I am logged in as "data.provider@intersect.org.au"
    And I create a response for "MySurvey" with baby code "ABC123"
    When I follow "Sec2"
    Then I should see questions
      | Sect2 Q1 |
      | Sect2 Q2 |
    When I follow "Sec3"
    Then I should see questions
      | Sect3 Q1 |
      | Sect3 Q2 |
    When I follow "Sec1"
    Then I should see questions
      | Sect1 Q1 |
      | Sect1 Q2 |

  Scenario: When saving, same section is redisplayed
    Given I am logged in as "data.provider@intersect.org.au"
    And I create a response for "MySurvey" with baby code "ABC123"
    When I follow "Sec2"
    And I press "Save page"
    Then I should see questions
      | Sect2 Q1 |
      | Sect2 Q2 |

  Scenario: Answers on current page are saved when navigating to another section
    Given I am logged in as "data.provider@intersect.org.au"
    And I create a response for "MySurvey" with baby code "ABC123"
    And I answer "Sect1 Q2" with "5678"
    When I follow "Sec2"
    Then the answer to "Sect1 Q2" should be "5678"
    And I should see questions
      | Sect2 Q1 |
      | Sect2 Q2 |
