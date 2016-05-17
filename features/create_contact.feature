Feature: Create Contact

  Scenario: Create new contact successfully
    Given I am authenticated as partner
    And   external registries are defined
    When  I create a new contact
    Then  contact must be created
    And   create contact must be synced to other systems

  Scenario Outline: Invalid parameters
    Given I am authenticated as partner
    When  I create a new contact <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter     | field   | code            |
      | with empty request    | handle  | invalid         |
      | with existing handle  | handle  | already_exists  |
