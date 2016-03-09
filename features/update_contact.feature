Feature: Update Contact

  Scenario: Update contact successfully
    Given I am authenticated as partner
    When  I update a contact
    Then  contact must be updated
    And   update contact must be synced to other systems

  Scenario Outline: Invalid parameters
    Given I am authenticated as partner
    When  I update a contact <invalid update>
    Then  error must be <error>

    Examples:
      | invalid update                | error       |
      | that does not exist           | not found   |
      | with a new handle             | bad request |
      | to another partner            | bad request |
      # | that I do not own             | not found   |

  Scenario: Update a contact as administrator successfully
    Given I am authenticated as administrator
    When  I update a contact
    Then  contact must be updated
    And   update contact must not be synced to other systems


  Scenario Outline: Invalid administrator parameters
    Given I am authenticated as administrator
    When  I update a contact <invalid update>
    Then  error must be <error>

    Examples:
      | invalid update                | error       |
      | that does not exist           | not found   |
      | with a new handle             | bad request |
      | to another partner            | bad request |
