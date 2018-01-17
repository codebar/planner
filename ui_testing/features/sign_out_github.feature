Feature: Sign out

  Scenario: as a user I want to be able to sign in
    Given I am on the landing page
    When I sign up as a student
    And I accept criterias
    And I login to GitHub
    Then I will have signed up

  Scenario: as a user I want to be able to sign out
    Given I am on the Github page
    When I click on the icon
    And I sign out
    Then I have signed out
