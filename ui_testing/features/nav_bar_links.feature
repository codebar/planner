Feature: I can go to the appropriate pages when I click on the links

  Scenario: As a user I can go to the Blog site
    Given I am on the landing page
    When I click on Blog link
    Then I go to Medium page

  Scenario: As a user I can go to the Events site
    Given I am on the landing page
    When I click on Events link
    Then I go to the events page

  Scenario: As a user I can go to the Tutorials site
    Given I am on the landing page
    When I click on Tutorials link
    Then I go to the tutorials page

  Scenario: As a user I can go to the Coaches site
    Given I am on the landing page
    When I click on Coaches link
    Then I go to Coaches page

  Scenario: As a user I can go to the Sponsors site
    Given I am on the landing page
    When I click on Sponsors link
    Then I go to Sponsors page

  Scenario: As a user I can go to the Jobs site
    Given I am on the landing page
    When I click on Jobs link
    Then I go to Jobs page
