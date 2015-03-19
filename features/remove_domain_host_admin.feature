Feature: Remove Domain Host as Administrator
  As an Administrator
  I want to remove domain host entries from existing domains of other non-admin partners

  Background:
    Given I am authenticated as administrator

  Scenario: Successfully remove domain host entry
    When  I remove a domain host entry from an existing domain
    Then  domain host entry must be removed
    And   domain status must be ok

  @wip
  Scenario: Remove all domain host entries
    When  I remove all domain host entries of an existing domain
    Then  domain status must be inactive

  Scenario: Domain does not exist
    When  I remove a domain host entry of a non-existing domain
    Then  error must be not found

  Scenario: Domain host does not exist
    When  I remove a domain host entry that does not exist
    Then  error must be not found
