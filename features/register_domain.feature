Feature: Register Domain

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Register domain
    When  I register a domain
    Then  domain must be registered
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted
    And   register domain must be synced to external registries

  Scenario: Register domain with two-level TLD
    When  I register a domain with two-level TLD
    Then  domain with two-level TLD must be registered

  Scenario: Register domain before registrant exists
    When  I register a domain before registrant exists
    Then  domain must be registered
    And   registrant must be checked until available

  Scenario: Register domain where registrant does not exist
    When  I register a domain where registrant does not exist
    Then  register domain must reach max retries

  Scenario: Register domain which exceeds credit limit
    When  I register a domain that will exceed credit limit
    Then  register domain must not be registered

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I register a domain
    Then  domain must be registered
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted
    And   register domain must not be synced to external registries

  Scenario Outline: Invalid parameters
    When  I register a domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"
    And   register domain must not be synced to external registries

    Examples:
      | invalid parameter       | field             | code    |
      # | period with no pricing  | order_details     | invalid |
      | no domain name          | order_details     | invalid |
      | no period               | order_details     | invalid |
      | no registrant handle    | order_details     | invalid |
