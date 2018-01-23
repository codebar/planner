Feature: attending event
  As a user I should be able attend or not attend a workshop as a student

  @sub_student
  Scenario: As a user I should be able attend a workshop as a student
    Given I am on the dashboard page
    And I click on a random subscription workshop link
    When I click on attend as student
    Then I should see the appropriate message displayed

  Scenario: As a user I should be able to not attend a workshop as a student
    Given I start at the dashboard page
    And I click on a random subscription workshop link
    When I click to cancel my spot
    Then I should see the appropriate message displayed
