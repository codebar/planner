@sign_out_scenario
Feature: Signing out of Codebar

  Scenario: I should be able to successfully sign out

  Given that I am already logged in to codebar
  When I click the sign out button
  Then be redirected to the hompage
  And I should be signed out of my account
