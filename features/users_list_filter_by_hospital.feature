Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I have the usual roles
    And I have hospitals
      | state | name       |
      | NSW   | Hospital 2 |
      | Vic   | Hospital 3 |
      | Vic   | H4         |
      | NSW   | Left Wing  |
      | Vic   | Right Wing |
      | Vic   | Only Wing  |
    And I have users
      | email                 | first_name | last_name | role                     | hospital   |
      | fred@intersect.org.au | Fred       | Jones     | Data Provider Supervisor | Left Wing  |
      | dan@intersect.org.au  | TheManDan  | Superuser | Administrator            |            |
      | anna@intersect.org.au | Anna       | Smith     | Data Provider            | Right Wing |
      | bob@intersect.org.au  | Bob        | Smith     | Data Provider Supervisor | Left Wing  |
      | joe@intersect.org.au  | Joe        | Bloggs    | Data Provider            | H4         |
    And I am logged in as "dan@intersect.org.au"
    When I am on the list users page


  Scenario: Filter by hospital
    Then the filter by hospital select should contain
      |     | ANY, None                             |
      | NSW | Hospital 2, Left Wing                 |
      | Vic | H4, Hospital 3, Only Wing, Right Wing |
    When I select "Left Wing" from "Filter by hospital"
    And I press "Filter"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital        | Status |
      | Bob        | Smith     | bob@intersect.org.au  | Data Provider Supervisor | Left Wing (NSW) | Active |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW) | Active |
    And "Left Wing" should be selected in the "Filter by hospital" select

  Scenario: Filter by hospital = NONE
    When I select "None" from "Filter by hospital"
    And I press "Filter"
    Then I should see "users" table with
      | First name | Last name | Email                | Role          | Hospital |
      | TheManDan  | Superuser | dan@intersect.org.au | Administrator | (None)   |
    And "None" should be selected in the "Filter by hospital" select

  Scenario: Change from hospital filter back to ANY
    When I select "Left Wing" from "Filter by hospital"
    And I press "Filter"
    When I select "ANY" from "Filter by hospital"
    And I press "Filter"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active |
      | Bob        | Smith     | bob@intersect.org.au  | Data Provider Supervisor | Left Wing (NSW)  | Active |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Active |
      | Joe        | Bloggs    | joe@intersect.org.au  | Data Provider            | H4 (Vic)         | Active |

  Scenario: Sort while filtered by hospital retains filter
    When I select "Left Wing" from "Filter by hospital"
    And I press "Filter"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital        | Status |
      | Bob        | Smith     | bob@intersect.org.au  | Data Provider Supervisor | Left Wing (NSW) | Active |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW) | Active |
    When I follow "Last name"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital        | Status |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW) | Active |
      | Bob        | Smith     | bob@intersect.org.au  | Data Provider Supervisor | Left Wing (NSW) | Active |
    And "Left Wing" should be selected in the "Filter by hospital" select

  Scenario: Filter by hospital while sorted retains sort
    When I follow "Last name"
    And I select "Left Wing" from "Filter by hospital"
    And I press "Filter"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital        | Status |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW) | Active |
      | Bob        | Smith     | bob@intersect.org.au  | Data Provider Supervisor | Left Wing (NSW) | Active |

