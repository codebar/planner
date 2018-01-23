Feature: attending event
  As a user I should be able attend or not attend a workshop as a coach

  @sign_out
  Scenario: As a user I should be able attend a workshop as a coach
    Given I start at the dashboard page
    And I click on the twitter subscription workshop link
    When I click on attend as coach
    Then I should see the correct message displayed
