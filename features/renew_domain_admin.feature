Feature: Renew Domain as Administrator
  As an Administrator
  I want to be able to renew domains of other non-admin partners

  Scenario: Renew domain
    Given I am authenticated as administrator
    When  I renew an existing domain
    Then  domain must be renewed
    And   renew domain fee must be deducted from credits of non-admin partner

  @wip
  Scenario: Reverse domain renewal
    Given I am authenticated as administrator
    And   I renewed an existing domain
    When  I reverse the renewal order
    Then  domain must no longer be renewed
    And   renew domain fee must be added back to credits of non-admin partner
