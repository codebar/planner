Feature: Check job listing
  As an user, I can see job listings
  @sign_out
  @jobs
  Scenario: As a user, I should be able to view all job listings
    Given I start at the dashboard page
    When I click on the menu tab
    And I click on Jobs
    Then I should be able to see all the jobs listed
