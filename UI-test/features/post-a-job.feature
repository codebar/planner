Feature: Post a job position

  Scenario: As a coach post a job on the codebar site

    Given I am logged in
    When I click on the list a job option in the menu
    And I am sent to a page where I can enter the deatils of the job
    Then I should be able to input details of the job
    And click submit to confirm the job
    And See a notification telling me the job posting is being reviewed
