Feature: Register Domain as Administrator
  As an Administrator
  I want to be able to register new domains under specific partners

  Background:
    Given I am authenticated as administrator

  Scenario: Successfully register domain
    When  I register a domain
    Then  domain must be registered under non-admin partner
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   register domain fee must be deducted from credits of non-admin partner

  Scenario: Successfully register domain with 2-level TLD
    When  I register a domain with 2-level TLD
    Then  domain with 2-level TLD must be registered
    And   register domain fee must be deducted from credits of non-admin partner

  Scenario Outline: Invalid parameter
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
      | no partner              | partner           | missing |
      | non-existing partner    | partner           | invalid |
      | non-existing registrant | registrant_handle | invalid |
      | existing name           | domain            | invalid |
