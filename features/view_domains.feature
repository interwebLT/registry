Feature: View Domains
  In order to see a list of all my domains
  As a Partner
  I want to be able to view my domains

  Background:
    Given I am authenticated as partner

  Scenario: View domains
    When  I try to view my domains
    Then  I must see my domains

  Scenario: Search for a domain should succeed
    Given I have the domains foobar.ph, barbaz.ph, bazqux.ph
    When I search for bar
    Then I must see 2 domains

  Scenario: Search for a domain should log
    Given I have the domains foobar.ph, barbaz.ph, bazqux.ph
    When I search second level domains for bar
    Then the search log should have grown
