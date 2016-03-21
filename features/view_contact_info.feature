Feature: View Contact Info

  Scenario: View existing contact info
    Given I am authenticated as partner
    When  I try to view an existing contact info
    Then  I must see the contact info
