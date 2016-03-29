Feature: View Domain Info

  Scenario: View domain
    Given I am authenticated as partner
    When  I try to view the info of a domain that I own
    Then  I must see the info of my domain
