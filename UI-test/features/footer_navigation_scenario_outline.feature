Feature: Footer links page navigation

  Scenario Outline: Clicking on a footer link from the homepage takes us to the right page with the correct corresponding title

    Given I am on the homepage
    When I click on a link in the footer <link>
    Then I am sent to a page with the correct url <page_url>


    Examples:
    | link               | page_url                               |
    | Code of conduct    | code-of-conduct                           |
    | Coach guide        | effective-teacher-guide                   |
    | Student guide      | student-guide                             |
    | Tutorials          | tutorials.codebar.io/                     |
    | Becoming a sponsor | manual.codebar.io/becoming-a-sponsor      |
    | FAQ                | faq                                       |
    | Blog               | medium.com/the-codelog                    |
    | Coaches            | coaches                                   |
    | Sponsors           | sponsors                                  |
    | Events             | events                                    |
    | Jobs               | jobs                                      |
    | Donate             | donations/new                             |
    | Slack              | codebar-slack.herokuapp.com/              |
    | Github             | github.com/codebar                        |
    | Twitter            | twitter.com/codebar                       |
    | Facebook           | www.facebook.com/codebarHQ                |
