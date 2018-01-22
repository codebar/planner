Feature: attending event
  As a user I should be able attend a workshop as a student

  Scenario: As a user I should be able attend a workshop as a student
    Given I begin at the dashboard page
    And I click on a random subscription workshop link
    When I click on attend as student
    Then I should see the appropriate message displayed

  Scenario: As a user I should be able attend a workshop as a student
    Given I am on at the dashboard page
    When I click cancel my spot
    Then I should see the appropriate message displayed
