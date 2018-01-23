Feature: I am able to unsubscribe from a reigon

  Scenario: I am able to select which reigon I wish to unsubscribe from

  Given I am logged in and subscribed to a reigon
  When I select a reigon to unsubscribe
  Then I should be notified that I have been unsubscribed
