Feature: Add Domain Host

  Background:
    Given I am authenticated as partner
    And   external registries are defined

  #Scenario: Add domain host
  #  When  I try to add a domain host to an existing domain
  #  Then  domain must now have domain host
  #  And   add domain host must be synced to external registries

  #Scenario: Add domain host before domain is registered
  #  When  I try to add a domain host before domain is registered
  #  Then  domain must be checked until registered
  #  Then  domain must now have domain host

  #Scenario: Add domain host where domain does not exist
  #  When  I try to add a domain host where domain does not exist
  #  Then  add domain host must reach max retries
