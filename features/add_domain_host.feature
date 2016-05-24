Feature: Add Domain Host

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Add domain host
    When  I try to add a domain host to an existing domain
    Then  domain must now have domain host
    And   add domain host must be synced to other systems
