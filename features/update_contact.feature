Feature: Update Contact

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Update contact successfully
    When  I update a contact
    Then  contact must be updated
    And   update contact must be synced to other systems

  Scenario Outline: Invalid parameters
    When  I update a contact <invalid update>
    Then  error must be <error>

    Examples:
      | invalid update                | error       |
      | that does not exist           | not found   |
      # | that I do not own             | not found   |
