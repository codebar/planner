Feature: Attend Event

  Scenario: I am able to confirm I wish to attend an event

    Given that I am already signed in
    And I have clicked on an event on my dashboard
    When I confirm my attendance
    Then I should receive a notification saying that  a spot has been confirmed
    And a record of my confirmation should be registed on codebar's side
    And the dashboard should indicate that I am attending that particular event
