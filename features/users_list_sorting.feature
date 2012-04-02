Feature: Sort the list of users
  In order to quickly find what I'm looking for
  As an administrator
  I want to sort the list of current users

  Background:
    Given I have the usual roles
    And I have hospitals
      | state | name       | abbrev |
      | NSW   | Left Wing  | Left   |
      | Vic   | Right Wing | Right  |
      | Vic   | Only Wing  | OWing  |
    And I have users
      | email                 | first_name | last_name | last_sign_in_at  | role                     | hospital   |
      | fred@intersect.org.au | Fred       | Jones     | 2011-12-21 14:56 | Data Provider Supervisor | Left Wing  |
      | dan@intersect.org.au  | TheManDan  | Superuser |                  | Administrator            |            |
      | anna@intersect.org.au | Anna       | Smith     |                  | Data Provider            | Right Wing |
    And "fred@intersect.org.au" is deactivated
    And I am logged in as "dan@intersect.org.au"
    When I am on the list users page


  Scenario: List is initially sorted by email, clicking again reverses the order
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
    When I follow "Email"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |

  Scenario: Sorting by first name ascending/descending
    When I follow "First name"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
    When I follow "First name"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |

  Scenario: Sorting by last name ascending/descending
    When I follow "Last name"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
    When I follow "Last name"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |

  Scenario: Sorting by role ascending/descending
    When I follow "Role"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
    When I follow "Role"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |

  Scenario: Sorting by hospital ascending/descending
    When I follow "Hospital"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
    When I follow "Hospital"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |

  Scenario: Sorting by status ascending/descending
    When I follow "Status"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
    When I follow "Status"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |

  Scenario: Sorting by signin date ascending/descending
  # we're not actually checking the column, since the date changes each time the tests run, but dan is logged in now, fred logged in in 2011, anna never logged in
  # for sorting this ends up as fred, dan, anna ascending (i.e. older, newer, none) - which may be slightly counter intuitive but is acceptable given this will be used infrequently
    When I follow "Last signed in"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
    When I follow "Last signed in"
    Then I should see "users" table with
      | First name | Last name | Email                 | Role                     | Hospital         | Status      |
      | Anna       | Smith     | anna@intersect.org.au | Data Provider            | Right Wing (Vic) | Active      |
      | TheManDan  | Superuser | dan@intersect.org.au  | Administrator            | (None)           | Active      |
      | Fred       | Jones     | fred@intersect.org.au | Data Provider Supervisor | Left Wing (NSW)  | Deactivated |

