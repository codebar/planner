Feature: Sign up

  @sign-up-student
  Scenario: as a user I want to be able to sign up as a student
    Given I am on the landing page
    When I sign up as a student
    And I accept criterias
    And I login to GitHub
    Then I will have signed up

  @sign-up-coach
  Scenario: As a user I want to be able to sign up as a coach
    Given I am on the landing page
    When I sign up as a coach
    And I login to GitHub
    Then I will have signed up

  Scenario: As a user I want to be able to host a workshop
    Given I am on the landing page
    When I host a workshop
    Then I get redirected to the email app
