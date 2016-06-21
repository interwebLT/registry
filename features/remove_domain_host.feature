Feature: Remove Domain Host

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Remove domain host
    When  I try to remove a domain host from an existing domain
    Then  domain host must be removed
    And   remove domain host must be synced to external registries

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I try to remove a domain host from an existing domain
    Then  domain host must be removed
    And   remove domain host must not be synced to external registries
