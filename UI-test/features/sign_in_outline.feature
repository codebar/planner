Feature: Signing In to an account

  Scenario: Registered with Github, access account with Codebar

    Given I am on the homepage
    And I have clicked on the sign in link
    When i enter my github account details and press enter
    Then I am redirected to the dashbord page which includes my name as a link and a sidebar on the left hand side
