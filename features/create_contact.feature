Feature: Create Contact
  As a Partner
  I want to be able to create a new contact

  Background:
    Given I am authenticated as partner

  Scenario: Successfully create a new contact
    When  I create a new contact
    Then  contact must be created

  Scenario Outline: Bad request
    When  I create a new contact <bad request>
    Then  error must be bad request

    Examples:
      | bad request           |
      | with empty request    |
      | under another partner |

  Scenario Outline: Invalid parameter
    When  I create a new contact <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter     | field   | code            |
      | with existing handle  | handle  | already_exists  |
