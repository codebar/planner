Feature: Footer links are accessible
  As an user, when I click on a foot link, it redirects me to the right page

  Scenario: As a user I can access Code of Conduct
    Given I am in the homepage
    When I click in Code of Conduct in the footer
    Then I am redirected to the Code of Conduct page

  Scenario: As a user I can access Coach Guide
    Given I am in the homepage
    When I click in Tutorials in the footer
    Then I am redirected to the Tutorials page

  Scenario: As a user I can access Student Guide
    Given I am in the homepage
    When I click in Student Guide in the footer
    Then I am redirected to the Student guide page

  Scenario: As a user I can access Donate
    Given I am in the homepage
    When I click in Donate in the footer
    Then I am redirected to the Donates guide page

  Scenario: As a user I can access Tutorials
    Given I am in the homepage
    When I click in Tutorials in the footer
    Then I am redirected to the Tutorials page

  Scenario: As a user I can access Becoming a Sponsor
    Given I am in the homepage
    When I click in Becoming a Sponsor in the footer
    Then I am redirected to the Becoming a Sponsor page

  Scenario: As a user I can access FAQ
    Given I am in the homepage
    When I click in FAQ in the footer
    Then I am redirected to the FAQ page

  Scenario: As a user I can access Blog
    Given I am in the homepage
    When I click in Blog in the footer
    Then I am redirected to the Blog page

  Scenario: As a user I can access Events
    Given I am in the homepage
    When I click in Events in the footer
    Then I am redirected to the Events page

  Scenario: As a user I can access Jobs
    Given I am in the homepage
    When I click in Jobs in the footer
    Then I am redirected to the Jobs page
