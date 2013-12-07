Feature: New Member Signup
  As a new member
  In order to use the site
  I want to be able to sign up

  Scenario: Student with valid Credentials
    When a member signs up with no role
    Then a confirmation email should be sent
    And the email body should be correct
    And the email subject should be correct
    And the member should be redirected to the homepage
    And the 'sign up' message should be displayed
