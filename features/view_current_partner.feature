Feature: View Current Partner

  Scenario: View current partner
    Given I am authenticated as partner
    When  I view the info of the current partner
    Then  I must see my partner info
