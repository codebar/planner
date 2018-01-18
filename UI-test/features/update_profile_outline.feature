Feature: To update/edit account details

  Scenario: After account creation, change personal details

    Given that I am already signed in
    And the sidebar is already open
    And I have clicked the 'update your details' section
    When I have edited details displayed in the form
    And I have pressed save
    Then the changes are reflected on my profile page
