Feature: Create Host as Administrator
  As an Administrator
  I want to be able to create host entries under non-admin partners

  Background:
    Given I am authenticated as administrator

  Scenario: Sucessfully create host entry
    When  I create a host entry under a non-admin partner
    Then  host entry must be created under given partner

  Scenario Outline: Invalid parameters
    When  I create a host entry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter     | field   | code            |
      | no host name          | name    | missing         |
      | blank host name       | name    | invalid         |
      | existing host name    | name    | already_exists  |

    Examples: Administrator-specific
      | invalid parameter     | field   | code            |
      | no partner            | partner | missing         |
      | non-existing partner  | partner | invalid         |
      | other admin partner   | partner | invalid         |
