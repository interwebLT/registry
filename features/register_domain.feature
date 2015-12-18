Feature: Register Domain

  Scenario: Register domain successfully
    Given I am authenticated as partner
    When  I register a domain
    Then  domain must be registered
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted

  Scenario: Register domain with 2-level TLD successfully
    Given I am authenticated as partner
    When  I register a domain with 2-level TLD
    Then  domain with 2-level TLD must be registered

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

    Examples: Administrator-specific
      | invalid parameter       | field             | code    |
      # | no partner              | partner           | missing |
      # | non-existing partner    | partner           | invalid |
      # | non-existing registrant | registrant_handle | invalid |
      # | existing name           | domain            | invalid |
