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
      | survey   | year_of_registration | hospital          |
      | Survey A | 2009                 | RPA               |
      | Survey A | 2009                 | Mercy Hospital    |
      | Survey A | 2011                 | Royal North Shore |
      | Survey B | 2007                 | Mercy Hospital    |

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
      | ALL           |
      | 2007          |
      | 2009          |
      | 2011          |

  Scenario: Must fill in all fields to get a download

  Scenario: Message displayed when no data to download

  Scenario: Download all for a survey

  Scenario: Download by hospital for a survey

  Scenario: Download by year of registration for a survey

  Scenario: Download by hospital and year of registration for a survey

  Scenario: Dropdown selections should be retained on download

  Scenario: Data providers/Data provider supervisors can't download
