@sign_out_after_if_possible
Feature: See workshop invitations

  Scenario: I should be able to see workshop inviations and workshops I have already attended

    Given that the sidebar open
    And I press the invitations button
    And should see a list of upcoming and attended workshops
    When I click upcoming
    Then I should see upcoming workshops
