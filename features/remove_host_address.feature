Feature: Remove Host Address

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Remove host address
    When  I try to remove a host address from an existing host
    Then  host must no longer have host address
    # And   remove host address must not be synced to external registries
