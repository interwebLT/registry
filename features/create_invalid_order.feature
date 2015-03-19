Feature: Create Invalid Order
  As a Partner
  I should not be able to create an order with invalid data

  Scenario: No order details
    When  client sends order with no order details
    Then  error must be validation failed
    And   validation error on order_details must be "invalid"

  Scenario: Bad request
    When  client sends invalid order
    Then  error must be bad request
