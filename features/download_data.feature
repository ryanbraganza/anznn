Feature: Download survey data
  In order to use the data
  As an admin
  I want to be able to download all answers to a survey

  Background:
    And I am logged in as "admin@intersect.org.au" and have role "Administrator"
    And I have a survey with name "Survey B"
    And I have a survey with name "Survey A"
    And I have hospitals
      | name                         | state |
      | RPA                          | NSW   |
      | Royal North Shore            | NSW   |
      | Mercy Hospital               | Vic   |
      | The Royal Childrens Hospital | Vic   |
      | Sydney Childrens Hospital    | NSW   |
      | Another One                  | NSW   |
    And I have responses
      | survey   | year_of_registration | hospital          | baby_code |
      | Survey A | 2009                 | RPA               | A-2009-1  |
      | Survey A | 2009                 | Mercy Hospital    | A-2009-2  |
      | Survey A | 2011                 | Royal North Shore | A-2011-1  |
      | Survey B | 2007                 | Mercy Hospital    | B-2007-1  |

  Scenario: Download page dropdowns are populated appropriately
    Given I am on the home page
    When I follow "Download Data"
    Then the "Survey" select should contain
      | Please select |
      | Survey A      |
      | Survey B      |
    And the "Hospital" nested select should contain
      |     | ALL                                                            |
      | NSW | Another One, RPA, Royal North Shore, Sydney Childrens Hospital |
      | Vic | Mercy Hospital, The Royal Childrens Hospital                   |
    And the "Year of registration" select should contain
      | ALL  |
      | 2007 |
      | 2009 |
      | 2011 |

  Scenario: Must select a survey to get a download
    Given I am on the download page
    When I press "Download"
    Then I should see "Please select a survey" within the form errors

  Scenario: Message displayed when no data to download
    Given I am on the download page
    When I select "Survey B" from "Survey"
    And I select "2009" from "Year of registration"
    And I press "Download"
    Then I should see "No data was found for your search criteria" within the form errors

  Scenario: Download all for a survey

  Scenario: Download by hospital for a survey

  Scenario: Download by year of registration for a survey

  Scenario: Download by hospital and year of registration for a survey

  Scenario: Dropdown selections should be retained on page reload
    Given I am on the download page
    When I select "Survey B" from "Survey"
    And I select "Mercy Hospital" from "Hospital"
    And I select "2009" from "Year of registration"
    And I press "Download"
    Then "Survey B" should be selected in the "Survey" select
    Then "Mercy Hospital" should be selected in the "Hospital" select
    Then "2009" should be selected in the "Year of registration" select

  Scenario Outline: Data providers/Data provider supervisors can't download
    Given I am logged in as "dp@intersect.org.au" and have role "<role>"
    Then I should get a security error when I visit the download page
    Then I should get a security error when I visit the download link for the first survey
  Examples:
    | role                     |
    | Data Provider            |
    | Data Provider Supervisor |

