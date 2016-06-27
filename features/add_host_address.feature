Feature: Add Host Address

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Add host address
    When  I try to add a host address to an existing host
    Then  host must now have host address
