@sign_out_scenario
Feature: Signing in to Codebar

  Scenario: I should be able to sign in to Codebar given I halready have an account

  Given I am on the Homepage
  And I have clicked the sign in link
  When I enter my Github account details and press enter
  Then I am redirected to my profile page which has a button to the menu
