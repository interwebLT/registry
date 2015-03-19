Feature: Register Domain
  As a Partner
  I want to be able to register new domains

  Background:
    Given I am authenticated as partner

  Scenario: Successfully create pending register domain order
    When  I register a domain
    Then  pending register domain order is created

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
      | no registered at        | order_details     | invalid |
