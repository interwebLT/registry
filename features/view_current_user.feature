Feature: View Current User
  In order to see information related to my account
  As a Partner
  I want to be able to view the information of my account

  Scenario: View partner info
    Given I am authenticated as partner
    When  I try to view my partner information
    Then  I must see my partner information
