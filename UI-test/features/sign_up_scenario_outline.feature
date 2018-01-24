Feature: Sign up

  Scenario: Register as a student or coach, without a github account

    Given I am located on the homepage
    And I have  clicked on the sign up button
    And I have agreed that I understand that I meet the eligibility criteria
    When I click on the create account button
    Then I should be redirected to the github sign up page
