Feature: Migrate Domain

  Background:
    Given I am authenticated as partner

  Scenario: Migrate domain
    When  I migrate my domain into registry
    Then  domain must be migrated into my partner
    And   domain must not have domain hosts by default
    And   domain status must be inactive

  Scenario Outline: Invalid parameters
    When  I migrate a domain into registry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter               | field             | code    |
      | no domain name                  | name              | invalid |
      | no registrant handle            | registrant_handle | invalid |
      | no registered at                | registered_at     | invalid |
      | no expires at                   | expires_at        | invalid |
      | expires at before registered at | expires_at        | invalid |
