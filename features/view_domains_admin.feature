Feature: View Domains as Administrator
  In order to see the latest domains registered in my zone
  As a Administrator
  I want to be able to view my domains

  Scenario: View domains
    Given I am authenticated as administrator
    When  I try to view the latest domains registered in my zone
    Then  I must see the latest domains with newest first

