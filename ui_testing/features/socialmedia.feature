Feature: User can access social media platforms
  as I user I want to be able to access my social media platforms

  Scenario: As a user I can access Twitter
    Given I am in the homepage
    When I click on Twitter's icon in the footer
    Then I am redirected to Twitter's page

  Scenario: As a user I can access Github
    Given I am in the homepage
    When I click on Github's icon in the footer
    Then I am redirected to Github's page

  Scenario: As a user I can access Slack
    Given I am in the homepage
    When I click on Slack's icon in the footer
    Then I am redirected to Slack's page

  Scenario: As a user I can access Facebook
    Given I am in the homepage
    When I click on Facebbok's icon in the footer
    Then I am redirected to Facebook's page
