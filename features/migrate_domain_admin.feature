Feature: Migrate Domain as Administrator
  In order to move my domains into registry
  As an Administrator
  I want to be able to migrate my domains

  Background:
    Given I am authenticated as administrator

  Scenario: Migrate domain
    When  I migrate a domain into registry
    Then  domain must be migrated under non-admin partner
    And   domain must not have domain hosts by default
    And   domain status must be inactive
    And   migrate domain fee must be deducted from credits of non-admin partner

  Scenario: Invalid parameters
    When  I migrate a domain with no domain name
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"
