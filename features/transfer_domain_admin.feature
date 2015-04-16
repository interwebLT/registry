Feature: Transfer Domain as Administrator
  As an Administrator
  I want to be able to transfer domains from one partner to another

  @wip
  Scenario: Transfer domain
    When  I transfer a domain from another partner
    Then  domain must now be under my partner
