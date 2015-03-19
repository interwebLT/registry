Feature: View Partners
  In order to see a list of all partners in the registry
  As an Administrator
  I must be able to view all partners

  Background:
    Given I am authenticated as administrator

  Scenario: View partners
    When  I try to view a list of all partners
    Then  I must see a list of all partners

  Scenario: View partner info
    When  I try to view the info of a partner
    Then  I must see the info of the partner
