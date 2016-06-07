Feature: Migrate Domain

  Background:
    Given I am authenticated as partner

  Scenario: Migrate domain
    When  I migrate my domain into registry
    Then  domain must be migrated into my partner
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   no fees must be deducted from my credits

  Scenario Outline: Invalid parameters
    When  I migrate a domain into registry with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter               | field         | code    |
      | no domain name                  | order_details | invalid |
      | no registrant handle            | order_details | invalid |
      | no registered at                | order_details | invalid |
      | no expires at                   | order_details | invalid |
      | expires at before registered at | order_details | invalid |
