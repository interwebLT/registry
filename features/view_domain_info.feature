Feature: View Domain Info

  Background:
    Given I am authenticated as partner

  Scenario: View existing domain
    When  I try to view the info of an existing domain that I own
    Then  I must see the info of my domain

  Scenario: View existing domain owned by another partner
    When  I try to view the info an existing domain owned by another partner
    Then  I must not be able to see the domain

  Scenario: View existing domain by domain name
    When  I try to view the info of an existing domain that I own via domain name
    Then  I must see the info of my domain
