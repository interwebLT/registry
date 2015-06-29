Feature: Update Domain as Administrator
  As a Administrator
  I want to be able to update an existing domain of other non-admin partners

  Background:
    Given I am authenticated as administrator

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

  Scenario Outline: Set domain status
    When  I update an existing domain to <action> <status>
    Then  domain status <status> must be <action>
    And   latest object activity must be <action> <status>

    Examples:
      | action  | status                      |
      | set     | client hold                 |
      | set     | client delete prohibited    |
      | set     | client renew prohibited     |
      | set     | client transfer prohibited  |
      | set     | client update prohibited    |

  Scenario Outline: Unset domain status
    When  I update an existing domain that has <status> set to <action> <status>
    Then  domain status <status> must be <action>
    And   latest object activity must be <action> <status>

    Examples:
      | action  | status                      |
      | unset   | client hold                 |
      | unset   | client delete prohibited    |
      | unset   | client renew prohibited     |
      | unset   | client transfer prohibited  |
      | unset   | client update prohibited    |

  Scenario Outline: Non-boolean status values
    When  I update an existing domain with <invalid parameter>
    Then  response must be ok

    Examples:
      | invalid parameter                   |
      | invalid client hold                 |
      | invalid client delete prohibited    |
      | invalid client transfer prohibited  |
      | invalid client renew prohibited     |
      | invalid client update prohibited    |

  Scenario Outline: Invalid parameters
    When  I update an existing domain with <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter                   | field                       | code    |
      | blank registrant handle             | registrant_handle           | invalid |
      | non-existing registrant handle      | registrant_handle           | invalid |
      | non-existing admin handle           | admin_handle                | invalid |
      | non-existing billing handle         | billing_handle              | invalid |
      | non-existing tech handle            | tech_handle                 | invalid |
      | nil client hold                     | client_hold                 | invalid | 
      | nil client delete prohibited        | client_delete_prohibited    | invalid | 
      | nil client transfer prohibited      | client_transfer_prohibited  | invalid |
      | nil client renew prohibited         | client_renew_prohibited     | invalid |
      | nil client update prohibited        | client_update_prohibited    | invalid |
      | blank client hold                   | client_hold                 | invalid |
      | blank client delete prohibited      | client_delete_prohibited    | invalid |
      | blank client transfer prohibited    | client_transfer_prohibited  | invalid |
      | blank client renew prohibited       | client_renew_prohibited     | invalid |
      | blank client update prohibited      | client_update_prohibited    | invalid |

  Scenario: Update domain contact and status
    When  I update an existing domain to enable client hold but with invalid admin_handle
    Then  error must be validation failed
    And   validation error on admin_handle must be "invalid"
    And   domain status must not be client hold
