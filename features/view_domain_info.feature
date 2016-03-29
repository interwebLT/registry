Feature: View Domain Info

  Background:
    Given I am authenticated as partner

  Scenario: View domain
    When  I try to view the info of a domain that I own
    Then  I must see the info of my domain

  Scenario: View domain owned by another partner
    When  I try to view the info a domain owned by another partner
    Then  I must not be able to see the domain
