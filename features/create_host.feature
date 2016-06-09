Feature: Create Host

  Background:
    Given I am authenticated as partner

  @wip
  Scenario: Create host
    When  I create a host entry
    Then  host entry must be created under my partner

  @wip
  Scenario Outline: Invalid parameters
    When  I create a host entry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter   | field | code            |
      | no host name        | name  | invalid         |
      | existing host name  | name  | already_exists  |
