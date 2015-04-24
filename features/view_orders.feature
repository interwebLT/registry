Feature: View Orders
  In order to see a list of all my purchases
  As a Partner
  I want to be able to view my orders

  Scenario: View orders
    Given I am authenticated as partner
    When  I try to view my orders
    Then  I must see my orders
    And   I must not see any pending orders
    And   I must see my orders that were refunded
