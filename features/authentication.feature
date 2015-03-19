Feature: Authentication
  As I Partner or Administrator
  I want to authenticate with the system
  So I can transact with it

  Scenario: Successful authentication
    When  partner authenticates with valid credentials
    Then  partner receives authentication token

  Scenario Outline: Bad credentials
    When  partner authenticates with <invalid credentials>
    Then  response to client must be bad credentials

    Examples:
      | invalid credentials |
      | invalid scenario    |
      | invalid username    |
      | invalid password    |
      | no username         |
      | no password         |

