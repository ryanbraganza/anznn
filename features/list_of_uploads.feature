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
      | survey    | created_by                     | created_at       | status      | message   | hospital | summary report | detail report | file_file_name | record_count | year_of_registration |
      | MySurvey  | data.provider@intersect.org.au | 2012-01-03 13:56 | In Progress | Message 1 | RPA      | false          | false         | first.csv      |              | 2009                 |
      | MySurvey2 | data.provider@intersect.org.au | 2012-01-04 13:56 | In Progress | Message 2 | Randwick | false          | false         | second.csv     |              | 2010                 |
      | MySurvey  | supervisor@intersect.org.au    | 2012-01-03 08:00 | Succeeded   | Message 3 | Randwick | true           | false         | third.csv      | 15           | 2008                 |
      | MySurvey2 | supervisor@intersect.org.au    | 2012-01-03 11:23 | Failed      | Message 4 | RPA      | true           | true          | fourth.csv     | 20           | 2012                 |

  Scenario: View a list of batch uploads - superuser sees all
    Given I am logged in as "super@intersect.org.au" and have role "Administrator"
    When I am on the home page
    Then I should see "batch_uploads" table with
      | Survey Type | Year of Registration | Filename   | Created By    | Date Uploaded          | Num records | Status      | Details   | Reports                       |
      | MySurvey2   | 2010                 | second.csv | Data Provider | January 04, 2012 13:56 |             | In Progress | Message 2 |                               |
      | MySurvey    | 2009                 | first.csv  | Data Provider | January 03, 2012 13:56 |             | In Progress | Message 1 |                               |
      | MySurvey2   | 2012                 | fourth.csv | Fred Smith    | January 03, 2012 11:23 | 20          | Failed      | Message 4 | Summary Report\nDetail Report |
      | MySurvey    | 2008                 | third.csv  | Fred Smith    | January 03, 2012 08:00 | 15          | Succeeded   | Message 3 | Summary Report                |

  Scenario: View a list of batch uploads - data provider only sees own hospital
    Given I am logged in as "data.provider@intersect.org.au" and have role "Administrator"
    Given I am on the home page
    Then I should see "batch_uploads" table with
      | Survey Type | Filename   | Created By    | Date Uploaded          | Num records | Status      | Details   | Reports                       |
      | MySurvey    | first.csv  | Data Provider | January 03, 2012 13:56 |             | In Progress | Message 1 |                               |
      | MySurvey2   | fourth.csv | Fred Smith    | January 03, 2012 11:23 | 20          | Failed      | Message 4 | Summary Report\nDetail Report |

  Scenario: View a list of batch uploads - data provider supervisor only sees own hospital
    Given I am logged in as "supervisor@intersect.org.au"
    And I am on the home page
    Then I should see "batch_uploads" table with
      | Survey Type | Filename   | Created By    | Date Uploaded          | Num records | Status      | Details   | Reports                       |
      | MySurvey    | first.csv  | Data Provider | January 03, 2012 13:56 |             | In Progress | Message 1 |                               |
      | MySurvey2   | fourth.csv | Fred Smith    | January 03, 2012 11:23 | 20          | Failed      | Message 4 | Summary Report\nDetail Report |


  Scenario: Download a summary report
    Given I am logged in as "supervisor@intersect.org.au"
    And I am on the home page
    And I follow "Summary Report"
    Then I should receive a file with name "summary-report.pdf" and type "application/pdf"

  Scenario: Download a summary report
    Given I am logged in as "supervisor@intersect.org.au"
    And I am on the home page
    And I follow "Detail Report"
    Then I should receive a file with name "detail-report.csv" and type "text/csv"
