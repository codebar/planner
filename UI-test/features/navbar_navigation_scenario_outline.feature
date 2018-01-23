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
