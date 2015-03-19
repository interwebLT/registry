Feature: Remove Host Address as Administrator
  As an Administrator
  I want to remove host address entries from existing hosts of other non-admin partners

  Background:
    Given I am authenticated as administrator

  Scenario: Remove host address entry
    When  I remove a host address entry from an existing host
    Then  host must no longer have host address entry

  Scenario: Domain does not exist
    When  I try to remove a host address entry from a non-existing host
    Then  error must be not found

  Scenario: Host address does not exist
    When  I try to remove a host address entry that does not exist
    Then  error must be not found
