Feature: Update Contact as Administrator
  As an Administrator
  I want to update the domains of a contact of any partner

  Background:
    Given I am authenticated as administrator

  Scenario: Successfully update a contact
    When  I update a contact
    Then  contact must be updated

  Scenario Outline: Invalid request
    When  I update a contact <invalid update>
    Then  error must be <error>

    Examples:
      | invalid update                | error       |
      | that does not exist           | not found   |
      | with a new handle             | bad request |
      | to another partner            | bad request |
      | with an existing handle       | bad request |
