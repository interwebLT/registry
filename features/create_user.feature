Feature: Create User
  As a Partner
  I want to be able to create a new User

  Background:
    Given I am authenticated as partner

  Scenario: Successfully create a new user
    When  I create a new user
    Then  user must be created

  Scenario: Create a new user with no username
    When  I create a new user
    Then  user must be created

  Scenario: Create a new user with no registration date
    When  I create a new user with no registration date
    Then  user must be created with the current time as the registration date

  Scenario Outline: Bad request
    When  I create a new user <bad request>
    Then  error must be bad request

    Examples:
      | bad request           |
      | with empty request    |
      | with empty name       |
      | with empty email      |
      | with empty password   |

  Scenario Outline: Invalid parameter
    When  I create a new user <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter     | field   | code            |
      | with existing email   | email   | already_exists  |
