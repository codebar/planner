Feature: I can post a Job

  Scenario: As a coach, I am able to post a job

    Given I am logged in
    When I click on the list a job option in the menu
    Then I should be sent to a page where I can enter the deatils of the job
    And I enter all the required fields for the job and submit
    And I should be taken to a new page to confirm
    And I should be notifitief of my submission for a job posting
