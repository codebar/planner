@sign_out_after_if_possible
Feature: I am able to view and change my subscriptions

  Scenario: I am able to add and remove subscriptions when necessary

    Given I have the sidebar open
    When I have clicked manage subscriptions
    And I am redirected to the subscriptions page
    And I have clicked to subscribe to a particular reigon
    Then I should be notified that I have been subscribed to that particular reigon
