Feature: Renew Domain
  As a Partner
  I want to be able to renew my domains

  Background:
    Given I am authenticated as partner

  @wip
  Scenario: Successful renewal
    When  I renew my domain
    Then  pending domain renewal order is created
    And   transaction is successful



