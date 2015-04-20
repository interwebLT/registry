Feature: Delete Domain as Administrator
  As an Administrator
  I want to be able to delete domains under any partner

  Background:
    Given I am authenticated as administrator

  @wip
  Scenario: Delete domain
    When  I delete a domain that currently exists
    Then  domain must no longer exist
    And   domain must now be in the deleted domain list
