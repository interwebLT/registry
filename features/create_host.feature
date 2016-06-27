Feature: Create Host

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Create host
    When  I create a host entry
    Then  host entry must be created under my partner
    And   create host must be synced to external registries

  Scenario Outline: Invalid parameters
    When  I create a host entry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"
    And   create host must not be synced to external registries

    Examples:
      | invalid parameter   | field | code            |
      | no host name        | name  | invalid         |
      | existing host name  | name  | already_exists  |

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I create a host entry
    Then  host entry must be created under my partner
    But   create host must not be synced to external registries
