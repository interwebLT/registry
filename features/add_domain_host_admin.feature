Feature: Add Domain Host as Administrator
  As an Administrator
  I want to add domain host entries to existing domains of other non-admin partners

  Background:
    Given I am authenticated as administrator

  Scenario: Successfully add domain host entry
    When  I add a domain host entry to an existing domain
    Then  domain host entry must be created

  Scenario Outline: Invalid parameters
    When  I add a domain host entry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter | field | code            |
      | missing name      | name  | missing         |
      | blank name        | name  | invalid         |
      | existing name     | name  | already_exists  |
      #| no matching host  | name  | invalid         |

  Scenario: Domain does not exist
    When  I add a domain host entry for non-existing domain
    Then  error must be not found

  Scenario: Same domain host name used in different domains
    When  I add a domain host entry which is also used by another domain
    Then  domain host entry must be created
