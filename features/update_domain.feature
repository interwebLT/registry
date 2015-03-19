Feature: Update Domain
  As a Partner
  I want to be able to update an existing domain that I own

  Background:
    Given I am authenticated as partner

  Scenario Outline: Successfully update domain contact handles
    When  I update <contact handle> of my domain
    Then  <contact handle> of my domain must be updated

    Examples:
      | contact handle        |
      | all contact handles   |
      | the registrant handle |
      | the admin handle      |
      | the billing handle    |
      | the tech handle       |

  Scenario: Domain does not exist
    When  I update a domain that does not exist
    Then  error must be not found

  Scenario Outline: Invalid parameters
    When  I update an existing domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter               | field             | code    |
      | blank registrant handle         | registrant_handle | invalid |
      | non-existing registrant handle  | registrant_handle | invalid |
      | non-existing admin handle       | admin_handle      | invalid |
      | non-existing billing handle     | billing_handle    | invalid |
      | non-existing tech handle        | tech_handle       | invalid |
