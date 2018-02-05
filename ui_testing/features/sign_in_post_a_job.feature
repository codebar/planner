Feature: Posting a job
  As a user I should be able to post a job

  @sign_out
  Scenario: As a user I should be able attend a workshop as a student
    Given I start at the dashboard page
    And I click post a job in the menu tab
    When I submit the appropriate details
    Then I should see my posted job
