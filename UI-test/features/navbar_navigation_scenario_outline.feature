Feature: Navbar links page navigation

  Scenario Outline: Clicking on a navbar link from the homepage takes us to the right page with the correct corresponding title

    Given I am on the homepage
    When I click on a link in the navbar <link>
    Then I am sent to a page with the correct title <title>


    Examples:
    | link               | title                      |
    | Blog               | the codelog                |
    | Events             | no title                   |
    | Tutorials          | codebar tutorials          |
    | Coaches            | Coaches                    |
    | Sponsors           | Sponsors                   |
    | Jobs               | Jobs                       |
    | Donate             | Donations                  |
    | Logo               | Chapters                   |
    | Sign in            | no title                   |

  Scenario Outline: Clicking on a navbar link from the homepage when signed in takes us to the right page with the correct corresponding title

    Given I am on the homepage
    And I am logged in
    When I click on the navbar menu then click a link in the aside <link>
    Then I am sent to a page with the correct title <title>
    And I can logout


    Examples:
    | link                 | title               |
    | Jobs                 | Jobs                |
    | List a Job           | Post a job          |
    | My Profile           | My Profile          |
    | My Dashboard         | Dashboard           |
    | Invitations          | Invitations         |
    | Manage subscriptions | Subscriptions       |
    | Update your details  | Update your details |
    | Sign out             | ???                 |
