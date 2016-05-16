Feature: Authorization

  Scenario: Authorization token
    Given I am authenticated as partner
    When  I try to access secure data
    Then  I must be able to view the data

  Scenario: Invalid token
    When  I try to access secure data
    Then  I must not be able to view the data
