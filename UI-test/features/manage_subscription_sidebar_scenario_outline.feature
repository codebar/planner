@sign_out_scenario
Feature: Manage subscriptions from the sidebar

  Scenario: As a user, I should be able manage subscriptions from the sidebar

    Given that I have the sidebar open
    And I have clicked managed subscriptions
    And I have been redirected to the subscriptions page
    When I click to subscribe to a particuar region
    Then I should be notified that I have succesfully subscribed for a particular region
