@sign_out_scenario
Feature: Update Profile info

  Scenario: I should be able to change/update existing profile information

    Given I am already signed in
    And I have clicked on update your details section
    When I have edited my details in the form
    And I have clicked save
    Then the changes are reflected on my profile page
