Feature: Replenish Credits
  As a Partner
  I want to be able to replenish my credits

  Background:
    Given I am authenticated as administrator

  Scenario: Successful replenishment
    When  I replenish my credits
    Then  my balance should have changed



