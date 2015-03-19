Feature: Renew Domain as Administrator
  As an Administrator
  I want to be able to renew domains of other non-admin partners

  Scenario: Renew domain
    Given I am authenticated as administrator
    When  I renew an existing domain
    Then  domain must be renewed
    And   renew domain fee must be deducted from credits of non-admin partner



