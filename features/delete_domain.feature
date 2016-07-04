Feature: Delete Domain

  Background:
    Given I am authenticated as partner

  Scenario: Delete domain
    When  I delete a domain that currently exists
    Then  domain must no longer exist
    And   domain must now be in the deleted domain list
    And   deleted domain must not have domain hosts

  Scenario: Delete domain that does not exist
    When  I delete a domain that does not exist
    Then  error must be not found
