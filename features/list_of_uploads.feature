Feature: View a list of batch files
  In order to know the results of my upload
  As a data provider
  I want to view a list of batch files

  Background:
    Given I have a user "data.provider@intersect.org.au" with role "Data Provider" and hospital "RPA"
    Given I have a user "supervisor@intersect.org.au" with role "Data Provider Supervisor" and hospital "RPA"
    And I have a survey with name "MySurvey"
    And I have a survey with name "MySurvey2"
    And "supervisor@intersect.org.au" has name "Fred" "Smith"
    And "data.provider@intersect.org.au" has name "Data" "Provider"
    And I have batch uploads
      | survey    | created_by                     | created_at       | status      | message   | hospital |
      | MySurvey  | data.provider@intersect.org.au | 2012-01-03 13:56 | In Progress | Message 1 | RPA      |
      | MySurvey2 | data.provider@intersect.org.au | 2012-01-04 13:56 | In Progress | Message 2 | Randwick |
      | MySurvey  | supervisor@intersect.org.au          | 2012-01-03 08:00 | Succeeded   | Message 3 | Randwick |
      | MySurvey2 | supervisor@intersect.org.au          | 2012-01-03 11:23 | Failed      | Message 4 | RPA      |

  Scenario: View a list of batch uploads - superuser sees all
  Given I am logged in as "super@intersect.org.au" and have role "Administrator"
  When I am on the home page
  Then I should see "batch_uploads" table with
    | Survey Type | Created By    | Date Uploaded          | Status      | Details   |
    | MySurvey2   | Data Provider | January 04, 2012 13:56 | In Progress | Message 2 |
    | MySurvey    | Data Provider | January 03, 2012 13:56 | In Progress | Message 1 |
    | MySurvey2   | Fred Smith    | January 03, 2012 11:23 | Failed      | Message 4 |
    | MySurvey    | Fred Smith    | January 03, 2012 08:00 | Succeeded   | Message 3 |

Scenario: View a list of batch uploads - data provider only sees own hospital
  Given I am logged in as "data.provider@intersect.org.au" and have role "Administrator"
  Given I am on the home page
  Then I should see "batch_uploads" table with
    | Survey Type | Created By    | Date Uploaded          | Status      | Details   |
    | MySurvey    | Data Provider | January 03, 2012 13:56 | In Progress | Message 1 |
    | MySurvey2   | Fred Smith    | January 03, 2012 11:23 | Failed      | Message 4 |

Scenario: View a list of batch uploads - data provider supervisor only sees own hospital
  Given I am logged in as "supervisor@intersect.org.au"
  And I am on the home page
  Then I should see "batch_uploads" table with
    | Survey Type | Created By    | Date Uploaded          | Status      | Details   |
    | MySurvey    | Data Provider | January 03, 2012 13:56 | In Progress | Message 1 |
    | MySurvey2   | Fred Smith    | January 03, 2012 11:23 | Failed      | Message 4 |

