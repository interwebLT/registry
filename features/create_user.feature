Feature: Create User
  As a Partner
  I want to be able to create a new User

  Background:
    Given I am authenticated as partner

  Scenario: Successfully create a new user
    When  I create a new user
    Then  user must be created

  Scenario Outline: Bad request
    When  I create a new user <bad request>
    Then  error must be bad request

    Examples:
      | bad request           |
      | with empty request    |
      | under another partner |

  Scenario Outline: Invalid parameter
    When  I create a new user <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter     | field   | code            |
      | with existing handle  | handle  | already_exists  |
