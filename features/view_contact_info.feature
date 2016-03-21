Feature: View Contact Info

  Background:
    Given I am authenticated as partner

  Scenario: View existing contact info
    When  I try to view an existing contact info
    Then  I must see the contact info

  Scenario: View non-existing contact info
    When  I try to view a non-existing contact info
    Then  I must be notified that contact does not exist
