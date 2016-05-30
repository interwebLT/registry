Feature: Register Domain

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Register domain successfully
    When  I register a domain
    Then  domain must be registered
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted
    And   order must be synced to external registries

  Scenario: Register domain with two-level TLD successfully
    When  I register a domain with two-level TLD
    Then  domain with two-level TLD must be registered
    And   order must be synced to external registries

  Scenario Outline: Invalid parameters
    When  I register a domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter       | field             | code    |
      # | period with no pricing  | order_details     | invalid |
      | no domain name          | order_details     | invalid |
      | no period               | order_details     | invalid |
      | no registrant handle    | order_details     | invalid |
