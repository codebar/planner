Feature: User returns to homepage
  as I user I want to be able to go back to the homepage

  Scenario: If I click on the logo it should return to the homepage
    Given I am on the landing page
    When I click on the logo
    Then I return to the homepage
