Feature: Download survey data
  In order to use the data
  As an admin
  I want to be able to download all answers to a survey

  Background:
    And I am logged in as "admin@intersect.org.au" and have role "Administrator"
    And I have a survey with name "Survey B"
    And I have a survey with name "Survey A"
    And I have hospitals
      | name                         | state | abbrev |
      | RPA                          | NSW   | RPA    |
      | Royal North Shore            | NSW   | RNS    |
      | Mercy Hospital               | Vic   | MH     |
      | The Royal Childrens Hospital | Vic   | RCH    |
      | Sydney Childrens Hospital    | NSW   | SCH    |
      | Another One                  | NSW   | AO     |
    And I have responses
      | survey   | year_of_registration | hospital          | baby_code | submitted_status |
      | Survey A | 2009                 | RPA               | A-2009-1  | Submitted        |
      | Survey A | 2009                 | Mercy Hospital    | A-2009-2  | Submitted        |
      | Survey A | 2011                 | Mercy Hospital    | A-2011-1  | Submitted        |
      | Survey B | 2007                 | Royal North Shore | B-2007-1  | Submitted        |
      | Survey A | 2009                 | RPA               | A-2009-1U | Unsubmitted      |

  Scenario: Download page dropdowns are populated appropriately
    Given I am on the home page
    When I follow "Download Data"
    Then the "Survey" select should contain
      | Please select |
      | Survey A      |
      | Survey B      |
    And the "Hospital" nested select should contain
      |     | ALL                                                            |
      | NSW | Another One, Royal North Shore, RPA, Sydney Childrens Hospital |
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

  #TODO: the following tests don't check the full answer details in the files, as this is already tested in csv_generator_spec.rb,
  # however it would be nice to have a full end to end test that checks that
  Scenario: Download all for a survey
    Given I am on the download page
    When I select "Survey A" from "Survey"
    And I press "Download"
    Then I should receive a file with name "survey_a.csv" and type "text/csv"
    And the file I received should match "survey_a.csv"

  Scenario: Download by hospital for a survey
    Given I am on the download page
    When I select "Survey A" from "Survey"
    And I select "Mercy Hospital" from "Hospital"
    And I press "Download"
    Then I should receive a file with name "survey_a_mh.csv" and type "text/csv"
    And the file I received should match "survey_a_mh.csv"

  Scenario: Download by year of registration for a survey
    Given I am on the download page
    When I select "Survey A" from "Survey"
    And I select "2009" from "Year of registration"
    And I press "Download"
    Then I should receive a file with name "survey_a_2009.csv" and type "text/csv"
    And the file I received should match "survey_a_2009.csv"

  Scenario: Download by hospital and year of registration for a survey
    Given I am on the download page
    When I select "Survey A" from "Survey"
    And I select "2009" from "Year of registration"
    And I select "Mercy Hospital" from "Hospital"
    And I press "Download"
    Then I should receive a file with name "survey_a_mh_2009.csv" and type "text/csv"
    And the file I received should match "survey_a_mh_2009.csv"

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

