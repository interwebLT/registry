Feature: Whois

  Scenario: Whois info of an existing domain
    When  I try to view the whois info of an existing domain
    Then  I must see the whois info of the domain

  Scenario: Whois info of a non-existing domain
    When  I try to view the whois info of a non-existing domain
    Then  I must be notified that domain does not exist

  @wip
  Scenario: Whois info of an invalid domain
    When  I try to view the whois info of an invalid domain
    Then  I must be notified that domain does not exist

