Feature: Renew Domain

  Scenario: Renew existing domain successfully
    Given I am authenticated as partner
    When  I renew an existing domain
    Then  domain must be renewed
    And   renew domain fee must be deducted
    And   order must be synced to other systems

  Scenario: Renew existing domain with two-level TLD successfully
    Given I am authenticated as partner
    When  I renew an existing domain with two-level TLD
    Then  domain with two-level TLD must be renewed
    And   order must be synced to other systems

  @wip
  Scenario: Renew non-existing domain
    Given I am authenticated as partner
    When  I renew a non-existing domain
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  @wip
  Scenario: Renew existing domain that another partner owns
    Given I am authenticated as partner
    When  I renew an existing domain under another partner
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  Scenario Outline: Invalid parameters
    Given I am authenticated as partner
    When  I renew an existing domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter       | field         | code    |
      #| period with no pricing  | order_details | invalid |
      | no domain name          | order_details | invalid |
      | no period               | order_details | invalid |

  Scenario: Renew existing domain as administrator successfully
    Given I am authenticated as administrator
    When  I renew an existing domain for another partner
    Then  domain must be renewed
    And   renew domain fee must be deducted
    And   order must not be synced to other systems

  @wip
  Scenario: Renew non-existing domain as administrator
    Given I am authenticated as partner
    When  I renew a non-existing domain for another partner
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  @wip
  Scenario: Renew existing domain under another partner as administrator
    Given I am authenticated as partner
    When  I renew an existing domain for another partner under another partner
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  Scenario Outline: Invalid administrator parameters
    Given I am authenticated as administrator
    When  I renew an existing domain for another partner with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter       | field         | code    |
      #| period with no pricing  | order_details | invalid |
      | no domain name          | order_details | invalid |
      | no period               | order_details | invalid |

    Examples: Administrator-specific
      | invalid parameter       | field             | code    |
      | no partner              | partner           | missing |
      | non-existing partner    | partner           | invalid |
