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

  Scenario: Add host address before host exists
    When  I try to add a host address before host exists
    Then  host must be checked until available
    And   host must now have host address

  Scenario: Add host address where host does not exist
    When  I try to add a host address where host does not exist
    Then  create host address must reach max retries
