Feature: Navbar links page navigation

  Scenario Outline: Clicking on a navbar link from the homepage takes us to the right page with the correct corresponding title

    Given I am on the homepage
    When I click on a link in the navbar <link>
    Then I am sent to a page with the correct url <page_url>


    Examples:
    | link        | page_url                     |
    | Blog        | medium.com/@codebar          |
    | Events      | localhost:3000/events        |
    | Tutorials   | tutorials.codebar.io/        |
    | Coaches     | localhost:3000/coaches       |
    | Sponsors    | localhost:3000/sponsors      |
    | Jobs        | localhost:3000/jobs          |
    | Donate      | localhost:3000/donations/new |
    | Logo        | localhost:3000/              |
    | Sign in     | github.com/login             |
