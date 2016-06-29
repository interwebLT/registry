Feature: Add Host Address

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Add host address
    When  I try to add a host address to an existing host
    Then  host must now have host address
    And   add host address must be synced to external registries

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I try to add a host address to an existing host
    Then  host must now have host address
    But   add host address must not be synced to external registries