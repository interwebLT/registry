Feature: View Domains
  In order to see a list of all my domains
  As a Partner
  I want to be able to view my domains

  Background:
    Given I am authenticated as partner

  Scenario: View domains
    When  I try to view my domains
    Then  I must see my domains

  Scenario: View domain info
    When  I try to view the info of one of my domains
    Then  I must see the info of my domain

  Scenario: View domain with complete contacts
    When  I try to view the info of a domain with complete contacts
    Then  I must see the info of my domain with all contacts

