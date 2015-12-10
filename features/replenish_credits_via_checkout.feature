Feature: Replenish Credits Via Checkout
  As a Partner
  I want to be able to replenish my credits

  Background:
    Given I am authenticated as partner

  Scenario: Successful replenishment
    When  I replenish my credits via checkout
    Then  my balance should have changed