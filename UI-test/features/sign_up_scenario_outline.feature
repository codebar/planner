Feature: Sign up

  Scenario: Register as a student or coach, without a github account

    Given I am on the homepage
    And I have  clicked on the sign up button
    And i have agreed that I meet the criteria
    When I click on the create account button
    Then I should be redirected to the github sign up page
