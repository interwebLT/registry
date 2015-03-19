Feature: View Credits
  In order to see a list of all my credit transactions
  As a Partner
  I want to view my credit history

  Scenario: View credit history
    Given I am authenticated as partner
    When  I try to view my credit history
    Then  I must see my credit history
    And   I must not see any pending credit orders
