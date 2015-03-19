Feature: Add Host Address as Administrator
  As an Administrator
  I want to add host address entries to existing host entries of other non-admin partners

  Background:
    Given I am authenticated as administrator

  Scenario: Successfully add host address entry
    When  I add a host address entry to an existing host
    Then  host address must be created

  Scenario Outline: Invalid parameters
    When  I add a host address entry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter | field   | code            |
      | missing address   | address | missing         |
      | blank address     | address | invalid         |
      | missing type      | type    | missing         |
      | blank type        | type    | invalid         |
      | invalid type      | type    | invalid         |
      | existing address  | address | already_exists  |

  Scenario: Host does not exist
    When  I add a host address entry for non-existing host
    Then  error must be not found

  Scenario: Same host address used in different hosts
    When  I add a host address entry which is also used by another host
    Then  host address must be created
