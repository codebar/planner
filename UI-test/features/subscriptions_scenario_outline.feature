Feature: I am able to view and change my subscritpions

  Scenario: I am able to add and remoe subsriptions when neccesary

    Given I have the sidebar open
    When I have clicked manage subscriptions
    And I have been redirected to the subsriptions page
    And I have clicked to subscribe to a particular reigon
    Then I should be notified that I have been subscribed to that particular reigon
