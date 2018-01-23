Feature: Signing out
  As a user I should be able to sign out

  @sub_student
  Scenario: As a user I should be able to sign out
    Given I start at the dashboard page
    And I click on the menu tab
    When I click on the Sign out link
    Then I should successfully be signed out.
