Feature: Create Contact

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Create new contact
    When  I create a new contact
    Then  contact must be created
    And   create contact must be synced to external registries

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I create a new contact
    Then  contact must be created
    And   create contact must not be synced to external registries

  Scenario Outline: Invalid parameters
    When  I create a new contact <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"
    And   create contact must not be synced to external registries

    Examples:
      | invalid parameter     | field   | code            |
      | with empty request    | handle  | invalid         |
      | with existing handle  | handle  | already_exists  |
