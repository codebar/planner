Feature: Footer links page navigation

  Scenario Outline: Clicking on a footer link from the homepage takes us to the right page with the correct corresponding title

    Given I am on the homepage
    When I click on a link in the footer <link>
    Then I am sent to a page with the correct title <title>


    Examples:
    | link               | title                      |
    | Code of conduct    | Code of conduct            |
    | Coach guide        | Coach Guide                |
    | Student guide      | Student Guide              |
    | Tutorials          | codebar tutorials          |
    | Becoming a sponsor | codebar's Manual           |
    | FAQ                | Frequently Asked Questions |
    | Blog               | the codelog                |
    | Coaches            | Coaches                    |
    | Sponsors           | Sponsors                   |
    | Events             | no title                   |
    | Jobs               | Jobs                       |
    | Donate             | Donations                  |
    | Slack              | no title                   |
    | Github             | codebar                    |
    | Twitter            | codebar                    |
    | Facebook           | codebar.io                 |
