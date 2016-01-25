Feature: Create Contact

  Scenario: Create new contact successfully
    Given I am authenticated as partner
    When  I create a new contact
    Then  contact must be created

  Scenario Outline: Bad request
    Given I am authenticated as partner
    When  I create a new contact <bad request>
    Then  error must be bad request

    Examples:
      | bad request           |
      | with empty request    |
      | under another partner |

  Scenario Outline: Invalid parameters
    Given I am authenticated as partner
    When  I create a new contact <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter     | field   | code            |
      | with existing handle  | handle  | already_exists  |

  Scenario: Create new contact as administrator successfully
    Given I am authenticated as administrator
    When  I create a new contact
    Then  contact must be created

  Scenario Outline: Bad administrator request
    Given I am authenticated as administrator
    When  I create a new contact <bad request>
    Then  error must be bad request

    Examples:
      | bad request         |
      | with empty request  |

  Scenario Outline: Invalid administrator parameters
    Given I am authenticated as administrator
    When  I create a new contact <invalid parameter>
    Then  error must be validation failed
    And   validation error on <field> must be "<code>"

    Examples:
      | invalid parameter           | field   | code            |
      | with existing handle        | handle  | already_exists  |
      | under another admin partner | partner | invalid         |
      | with empty partner          | partner | invalid         |
      | with non-existing partner   | partner | invalid         |
