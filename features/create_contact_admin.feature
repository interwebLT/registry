Feature: Create Contact as Administrator
  As an Administrator
  I want to be able to create a contact under another non-admin partner

  Background:
    Given I am authenticated as administrator

  Scenario: Successfully create a new contact
    When  I create a new contact
    Then  contact must be created

  Scenario Outline: Bad request
    When  I create a new contact <bad request>
    Then  error must be bad request

    Examples:
      | bad request         |
      | with empty request  |

  Scenario Outline: Invalid parameter
    When  I create a new contact <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter           | field   | code            |
      | with existing handle        | handle  | already_exists  |
      | under another admin partner | partner | invalid         |
      | with empty partner          | partner | invalid         |
      | with non-existing partner   | partner | invalid         |
