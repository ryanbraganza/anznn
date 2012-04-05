Feature: Navigation
  In order to see the status of my survey responses
  As a data provider
  I want to see a list of survey responses

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have a survey with name "survey" and questions
      | question  |
      | Choice Q1 |
      | Choice Q2 |
    Given I have a user "other.provider@intersect.org.au" with role "Data Provider" and hospital "Other"
    Given I have a user "data.supervisor@intersect.org.au" with role "Data Provider Supervisor" and hospital "RPA"
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode123" and year of registration "2009"
    And "data.provider@intersect.org.au" created a response to the "survey" survey with babycode "babycode456" and year of registration "2011" and submitted it
    And "other.provider@intersect.org.au" created a response to the "survey" survey with babycode "babyother" and year of registration "2007"

  Scenario: See an informative message when there are no responses in progress
    Given I am logged in as "data.provider@intersect.org.au"
    And there are no survey responses
    When I am on the home page
    Then I should see "There are no surveys in progress."

  Scenario Outline: Data providers and data provider supervisors see a list of incomplete surveys from their own hospital
    Given I am logged in as "<user>"
    When I am on the home page
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  | Year of Registration |
      | babycode123 | survey      | Fred Bloggs | 2009                 |
    And I should see link "Start New Survey Response"
  Examples:
    | user                             |
    | data.provider@intersect.org.au   |
    | data.supervisor@intersect.org.au |

  Scenario Outline: Data providers and data provider supervisors can edit a listed survey
    Given I am logged in as "<user>"
    When I am on the home page
    And I follow "Edit"
    Then I should be on the response page for babycode123
  Examples:
    | user                             |
    | data.provider@intersect.org.au   |
    | data.supervisor@intersect.org.au |

  Scenario Outline: Everyone can view summary for a listed survey
    Given I am logged in as "<user>"
    When I am on the home page
    And I follow "View Summary"
    Then I should be on the response summary page for babycode123
  Examples:
    | user                             |
    | data.provider@intersect.org.au   |
    | data.supervisor@intersect.org.au |
    | admin@intersect.org.au           |

  Scenario Outline: Everyone can review answers for a listed survey
    Given I am logged in as "<user>"
    When I am on the home page
    And I follow "Review Answers"
    Then I should be on the review answers page for babycode123
  Examples:
    | user                             |
    | data.provider@intersect.org.au   |
    | data.supervisor@intersect.org.au |
    | admin@intersect.org.au           |

  Scenario Outline: Data providers and data provider supervisors can only get to surveys from their own hospital
    Given I am logged in as "<user>"
    When I go to the response page for babycode123
    Then I should be on the response page for babycode123
    And I should get a security error when I visit the response page for babyother
  Examples:
    | user                             |
    | data.provider@intersect.org.au   |
    | data.supervisor@intersect.org.au |

  Scenario: superusers can see all unsubmitted responses and can view but not edit/create
    Given I am logged in as "admin@intersect.org.au"
    When I am on the home page
    Then I should see "responses" table with
      | Baby Code   | Survey Type | Created By  |
      | babycode123 | survey      | Fred Bloggs |
      | babyother   | survey      | Fred Bloggs |
    And I should not see link "Start New Survey Response"
    And I should not see link "Edit"
    And I should see link "Review Answers"
    And I should see link "View Summary"
    Then I should get a security error when I visit the response page for babyother
    Then I should get a security error when I visit the new response page
