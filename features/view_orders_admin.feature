Feature: View Orders as Administrator
  In order to see the latest purchases in my zone
  As an Administrator
  I want to see the latest orders

  Scenario: View latest orders
    Given I am authenticated as administrator
    When  I try to view the latest purchases in my zone
    Then  I must see the latest orders
