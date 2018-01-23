Feature: User adding new subscriptions
  As a user, I should be able to add new subscriptions

  @sign_out
  Scenario: As a user, I should be able to add new subscriptions as a student
    Given I start at the dashboard page
    And I click on the edit link next to subscriptions.
    When I click on any chapter student subscription
    Then I should see the appropriate success message informing the user has subscribed as a student
