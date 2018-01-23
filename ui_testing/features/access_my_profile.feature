Feature: Access profile
  As an user, I can access my profile

  Scenario: As a user, I should be able to access my profile
    Given I am on the dashboard page
    When I click on the menu tab
    And I click on My Profile
    Then I should be able to see my profile
