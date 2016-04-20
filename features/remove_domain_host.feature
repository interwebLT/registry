Feature: Remove Domain Host

  Background:
    Given I am authenticated as partner

  Scenario: Remove domain host
    When  I try to remove a domain host from an existing domain
    Then  domain host must be removed
