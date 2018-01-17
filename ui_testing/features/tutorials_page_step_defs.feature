Feature: I can access the tutorials
  As an User, when I click on a tutorial, the right page opens

  Scenario: As a user I can access all the tutorials on Github
    Given I am in the tutorials page
    When I click View our tutorials on Github
    Then I am redirected to https://github.com/codebar/tutorials

  Scenario: As a user I can join the codebar community on Slack
    Given I am in the tutorials page
    When I click Join the codebar community
    Then I am redirected to https://codebar-slack.herokuapp.com/

  Scenario: As a user I can access the Guide for Students
    Given I am in the tutorials page
    When I click Guide for Students
    Then I am redirected to http://tutorials.codebar.io/general/setup/tutorial.html

  Scenario: As a user I can access the Guide for coaches
    Given I am in the tutorials page
    When I click Guide for coaches
    Then I am redirected to http://tutorials.codebar.io/coaches/lesson-guide.html

  Scenario: As a user I can access Introducing HTML
    Given I am in the tutorials page
    When I click Introducing HTML
    Then I am redirected to http://tutorials.codebar.io/html/lesson1/tutorial.html

  Scenario: As a user I can access Introducing CSS
    Given I am in the tutorials page
    When I click Introducing CSS
    Then I am redirected to http://tutorials.codebar.io/html/lesson2/tutorial.html

  Scenario: As a user I can access Beyond the basics
    Given I am in the tutorials page
    When I click Beyond the basics
    Then I am redirected to http://tutorials.codebar.io/html/lesson3/tutorial.html

  Scenario: As a user I can access CSS, Layouts and formatting
    Given I am in the tutorials page
    When I click CSS, Layouts and formatting
    Then I am redirected to http://tutorials.codebar.io/html/lesson4/tutorial.html

  Scenario: As a user I can access Dive into HTML5 and CSS3
    Given I am in the tutorials page
    When I click Dive into HTML5 and CSS3
    Then I am redirected to http://tutorials.codebar.io/html/lesson5/tutorial.html

  Scenario: As a user I can access Advanced HTML5
    Given I am in the tutorials page
    When I click Advanced HTML5
    Then I am redirected to http://tutorials.codebar.io/html/lesson6/tutorial.html

  Scenario: As a user I can access Media queries and responsive design
    Given I am in the tutorials page
    When I click Media queries and responsive design
    Then I am redirected to http://tutorials.codebar.io/html/lesson7/tutorial.html

  Scenario: As a user I can access Introducing to JavaScript
    Given I am in the tutorials page
    When I click Introducing to JavaScript
    Then I am redirected to http://tutorials.codebar.io/js/lesson1/tutorial.html

  Scenario: As a user I can access Expressions, Loops and Arrays
    Given I am in the tutorials page
    When I click Expressions, Loops and Arrays
    Then I am redirected to http://tutorials.codebar.io/js/lesson2/tutorial.html

  Scenario: As a user I can access Introduction to jQuery
    Given I am in the tutorials page
    When I click Introduction to jQuery
    Then I am redirected to http://tutorials.codebar.io/js/lesson3/tutorial.html

  Scenario: As a user I can access HTTP Requests, AJAX and APIs
    Given I am in the tutorials page
    When I click HTTP Requests, AJAX and APIs
    Then I am redirected to http://tutorials.codebar.io/js/lesson4/tutorial.html

  Scenario: As a user I can access HTTP Requests, AJAX and API(part2)
    Given I am in the tutorials page
    When I click HTTP Requests, AJAX and API(part2)
    Then I am redirected to http://tutorials.codebar.io/js/lesson5/tutorial.html

  Scenario: As a user I can access Drawing in Canvas
    Given I am in the tutorials page
    When I click Drawing in Canvas
    Then I am redirected to http://tutorials.codebar.io/js/lesson6/tutorial.html

  Scenario: As a user I can access Introducing to Testing
    Given I am in the tutorials page
    When I click Introducing to Testing
    Then I am redirected to http://tutorials.codebar.io/js/lesson7/tutorial.html

  Scenario: As a user I can access Building your own app
    Given I am in the tutorials page
    When I click Building your own app
    Then I am redirected to http://tutorials.codebar.io/js/lesson8/tutorial.html

  Scenario: As a user I can access Introduction to Ruby
    Given I am in the tutorials page
    When I click Introduction to Ruby
    Then I am redirected to http://tutorials.codebar.io/ruby/lesson1/tutorial.html

  Scenario: As a user I can access Ruby Basics
    Given I am in the tutorials page
    When I click  Ruby Basics
    Then I am redirected to http://tutorials.codebar.io/ruby/lesson2/tutorial.html

  Scenario: As a user I can access Ruby Basics (part 2)
    Given I am in the tutorials page
    When I click Ruby Basics (part 2)
    Then I am redirected to http://tutorials.codebar.io/ruby/lesson3/tutorial.html

  Scenario: As a user I can access Object Oriented Ruby and Inheritance
    Given I am in the tutorials page
    When I click Object Oriented Ruby and Inheritance
    Then I am redirected to http://tutorials.codebar.io/ruby/lesson4/tutorial.html

  Scenario: As a user I can access Object Oriented Ruby and Inheritance (part 2)
    Given I am in the tutorials page
    When I click Object Oriented Ruby and Inheritance (part 2)
    Then I am redirected to http://tutorials.codebar.io/ruby/lesson5/tutorial.html

  Scenario: As a user I can access Installing Python
    Given I am in the tutorials page
    When I click Installing Python
    Then I am redirected to http://tutorials.codebar.io/python/lesson0/tutorial.html

  Scenario: As a user I can access Strings, Integers and Floats
    Given I am in the tutorials page
    When I click Strings, Integers and Floats
    Then I am redirected to http://tutorials.codebar.io/python/lesson1/tutorial.html

  Scenario: As a user I can access Playing with variables
    Given I am in the tutorials page
    When I click Playing with variables
    Then I am redirected to http://tutorials.codebar.io/python/lesson2/tutorial.html

  Scenario: As a user I can access Lists, Tuples and Dictionaries
    Given I am in the tutorials page
    When I click Lists, Tuples and Dictionaries
    Then I am redirected to http://tutorials.codebar.io/python/lesson3/tutorial.html

  Scenario: As a user I can access Fun with Functions
    Given I am in the tutorials page
    When I click Fun with Function
    Then I am redirected to http://tutorials.codebar.io/python/lesson4/tutorial.html

  Scenario: As a user I can access Python for you and Me
    Given I am in the tutorials page
    When I click Python for you and Me
    Then I am redirected to http://pymbook.readthedocs.io/en/latest/

  Scenario: As a user I can access Learn Python the Hard Way
    Given I am in the tutorials page
    When I click Learn Python the Hard Way
    Then I am redirected to https://learnpythonthehardway.org/book/

  Scenario: As a user I can access android tutorials
    Given I am in the tutorials page
    When I click on androids section link
    Then I am redirected to https://codebar.github.io/android-tutorials/

  Scenario: As a user I can access Introduction to PHP
    Given I am in the tutorials page
    When I click Introduction to PHP
    Then I am redirected to http://tutorials.codebar.io/php/lesson1/tutorial.html

  Scenario: As a user I can access Introduction to the command line
    Given I am in the tutorials page
    When I click Introduction to the command line
    Then I am redirected to http://tutorials.codebar.io/command-line/introduction/tutorial.html

  Scenario: As a user I can access Introduction to version control
    Given I am in the tutorials page
    When I click Introduction to version control
    Then I am redirected to http://tutorials.codebar.io/version-control/introduction/tutorial.html

  Scenario: As a user I can access Introduction to the git command line
    Given I am in the tutorials page
    When I click Introduction to the git command line
    Then I am redirected to http://tutorials.codebar.io/version-control/command-line/tutorial.html

  Scenario: As a user I can access Codewars website
    Given I am in the tutorials page
    When I click Codewars
    Then I am redirected to https://www.codewars.com/

  Scenario: As a user I can access Codecademy website
    Given I am in the tutorials page
    When I click Codecademy
    Then I am redirected to https://www.codecademy.com/learn
