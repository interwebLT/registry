Feature: Register Domain

  Scenario: Register domain successfully
    Given I am authenticated as partner
    When  I register a domain
    Then  domain must be registered
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted
    And   order must be synced to other systems

  Scenario: Register domain with two-level TLD successfully
    Given I am authenticated as partner
    When  I register a domain with two-level TLD
    Then  domain with two-level TLD must be registered
    And   order must be synced to other systems

  Scenario Outline: Invalid parameters
    Given I am authenticated as partner
    When  I register a domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter       | field             | code    |
      # | period with no pricing  | order_details     | invalid |
      | no domain name          | order_details     | invalid |
      | no period               | order_details     | invalid |
      | no registrant handle    | order_details     | invalid |

  Scenario: Register domain as administrator successfully
    Given I am authenticated as administrator
    When  I register a domain for another partner
    Then  domain must be registered
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted
    And   order must not be synced to other systems

  Scenario Outline: Invalid administrator parameters
    Given I am authenticated as administrator
    When  I register a domain for another partner with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter       | field             | code    |
      # | period with no pricing  | order_details     | invalid |
      | no domain name          | order_details     | invalid |
      | no period               | order_details     | invalid |
      | no registrant handle    | order_details     | invalid |

    Examples: Administrator-specific
      | invalid parameter       | field             | code    |
      | no partner              | partner           | missing |
      | non-existing partner    | partner           | invalid |
      | non-existing registrant | registrant_handle | invalid |
      # | existing name           | domain            | invalid |
