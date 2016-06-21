Feature: Update Contact

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Update existing contact
    When  I update an existing contact
    Then  contact must be updated
    And   update contact must be synced to external registries

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I update an existing contact
    Then  contact must be updated
    And   update contact must not be synced to external registries

  Scenario Outline: Invalid parameters
    When  I update a contact <invalid update>
    Then  error must be <error>
    And   update contact must not be synced to external registries

    Examples:
      | invalid update      | error       |
      | that does not exist | not found   |
      | that I do not own   | not found   |
