Feature: View Contacts
  In order to see a list of all contacts
  As an admin
  I want to be able to view all contacts

  Background:
    Given I am authenticated as administrator

  Scenario: View contacts
    When  I try to view contacts
    Then  I must see all contacts

