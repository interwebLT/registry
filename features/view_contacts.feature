Feature: View Contacts
  In order to see a list of all contacts
  As an admin
  I want to be able to view all contacts

  Scenario: View contacts
    Given I am authenticated as administrator
    When  I try to view contacts
    Then  I must see all contacts

  Scenario: View contacts without permission
    Given I am authenticated as staff
    When  I try to view contacts
    Then  I must see no contacts
