Feature: User adding new subscriptions
  As a user, I should be able to add a new subscription

  Scenario: As a user I should be able to add new subscriptions as a coach
    Given I am at the dashboard page
    And I click on the edit link next to subscriptions.
    When I click on any chapter coach subscription
    Then I should see the appropriate success message informing the user has subscribed or unsubscriped as a coach
