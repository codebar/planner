Feature: Update Details
  As an user, I can successfully update my profile details

  Scenario: As a user I am able to update the about me field
    Given I am in the Update Profile page
    When I change the about me section
    And press Save
    Then I can see my updated profile with a message Your details have been updated
