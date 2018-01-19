Feature: Make a donation
  As an user, when I click on donate, a pop up will come up for bank details

  Scenario: As a user I can make a donation
    Given I am on the Donate page
    When I fill the form
    And I donate
    Then it will ask for my bank details
