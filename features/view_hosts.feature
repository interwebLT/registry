Feature: View hosts
  In order to see a list of all hosts
  As an admin
  I want to be able to view all hosts

  @wip
  Scenario: View hosts
    Given I am authenticated as administrator
    When  I try to view hosts
    Then  I must see all hosts

  Scenario: View hosts without permission
    Given I am authenticated as staff
    When  I try to view hosts
    Then  I must see no hosts

  Scenario: View host info
    Given I am authenticated as administrator
    When  I try to view the info of a host
    Then  I must see the info of the host

  @wip
  Scenario: View host info without permission
    Given I am authenticated as staff
    When  I try to view the info of a host
    Then  I must see no host info
