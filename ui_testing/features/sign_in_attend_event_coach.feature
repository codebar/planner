Feature: attending event
  As a user I should be able attend or not attend a workshop as a coach

  @sign_out
  Scenario: As a user I should be able attend a workshop as a coach
    Given I start at the dashboard page
    And I click on the twitter subscription workshop link
    Then I should be taken to the correct page
