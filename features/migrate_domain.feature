Feature: Migrate Domain

  Background:
    Given I am authenticated as administrator

  Scenario: Migrate domain
    When  I migrate a domain into registry for another partner
    Then  domain must be migrated under non-admin partner
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   migrate domain fee must be deducted from credits of non-admin partner

  Scenario Outline: Invalid parameters
    When  I migrate a domain into registry for another partner with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter               | field         | code    |
      | no domain name                  | order_details | invalid |
      | no registrant handle            | order_details | invalid |
      | no registered at                | order_details | invalid |
      | no expires at                   | order_details | invalid |
      | expires at before registered at | order_details | invalid |
