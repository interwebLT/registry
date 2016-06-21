Feature: Renew Domain

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  Scenario: Renew existing domain
    When  I renew an existing domain
    Then  domain must be renewed
    And   renew domain fee must be deducted
    And   renew domain must be synced to external registries

  Scenario: Renew existing domain with two-level TLD
    When  I renew an existing domain with two-level TLD
    Then  domain with two-level TLD must be renewed

  Scenario: External registries unavailable
    When  I renew an existing domain which external registries reject
    #Then  domain must be renewed
    And   renew domain fee must be deducted
    And   renew domain must be synced to external registries
    And   exception must be thrown

  @wip
  Scenario: Renew non-existing domain
    When  I renew a non-existing domain
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  @wip
  Scenario: Renew existing domain that another partner owns
    When  I renew an existing domain under another partner
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  Scenario: Excluded from sync
    Given I am excluded from sync
    When  I renew an existing domain
    Then  domain must be renewed
    And   renew domain fee must be deducted
    And   renew domain must not be synced to external registries

  Scenario Outline: Invalid parameters
    When  I renew an existing domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"
    And   renew domain must not be synced to external registries

    Examples:
      | invalid parameter       | field         | code    |
      #| period with no pricing  | order_details | invalid |
      | no domain name          | order_details | invalid |
      | no period               | order_details | invalid |
