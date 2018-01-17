Feature: Access Tutorials
  As an User, when I click on a tutorial, the correspondent page opens

  # Scenario Outline: As a user if I click on a given link to be oppened in a new page, the correspondent page will open
  #   Given I am in the tutorials page
  #   When I click <ext_link>
  #   Then I am redirected to <ext_page>
  #
  #   Examples:
  #   | ext_link                                              | ext_page                                                    |
  #   | Join the codebar community on Slack                   | https://codebar-slack.herokuapp.com/                        |
  #   | https://codebar.github.io/android-tutorials/          | https://codebar.github.io/android-tutorials/                |

  Scenario Outline: As a user if I click on a given link, the correspondent page will open
    Given I am in the tutorials page
    When I press <link>
    Then the <page> opens

    Examples:
    | link                                                  | page                                                        |
    | View our tutorials on GitHub                          | https://github.com/codebar/tutorials                        |
    | Getting started guide for students.                   | http://tutorials.codebar.io/general/setup/tutorial.html     |
    | Lesson guide for coaches                              | http://tutorials.codebar.io/coaches/lesson-guide.html       |
    | Lesson 1 - Introducing HTML                           | http://tutorials.codebar.io/html/lesson1/tutorial.html      |
    | Lesson 2 - Introducing CSS                            | http://tutorials.codebar.io/html/lesson2/tutorial.html      |
    | Lesson 3 - Beyond the basics                          | http://tutorials.codebar.io/html/lesson3/tutorial.html      |
    | Lesson 4 - CSS, layouts and formatting                | http://tutorials.codebar.io/html/lesson4/tutorial.html      |
    | Lesson 5 - Dive into HTML5 & CSS3                     | http://tutorials.codebar.io/html/lesson5/tutorial.html      |
    | Lesson 6 - Advanced HTML5                             | http://tutorials.codebar.io/html/lesson6/tutorial.html      |
    | Lesson 7 - Media queries and responsive design        | http://tutorials.codebar.io/html/lesson7/tutorial.html      |
    | Lesson 1 - Introduction to JavaScript                 | http://tutorials.codebar.io/js/lesson1/tutorial.html        |
    | Lesson 2 - Expressions, Loops and Arrays              | http://tutorials.codebar.io/js/lesson2/tutorial.html        |
    | Lesson 3 - Introduction to jQuery                     | http://tutorials.codebar.io/js/lesson3/tutorial.html        |
    | Lesson 4 - HTTP Requests, AJAX and APIs               | http://tutorials.codebar.io/js/lesson4/tutorial.html        |
    | Lesson 5 - HTTP Requests, AJAX and APIs (part 2)      | http://tutorials.codebar.io/js/lesson5/tutorial.html        |
    | Lesson 6 - Drawing in Canvas                          | http://tutorials.codebar.io/js/lesson6/tutorial.html        |
    | Lesson 7 - Introduction to Testing                    | http://tutorials.codebar.io/js/lesson7/tutorial.html        |
    | Lesson 8 - Building your own app                      | http://tutorials.codebar.io/js/lesson8/tutorial.html        |
    | Lesson 1 - Introduction to Ruby                       | http://tutorials.codebar.io/ruby/lesson1/tutorial.html      |
    | Lesson 2 - Ruby Basics                                | http://tutorials.codebar.io/ruby/lesson2/tutorial.html      |
    | Lesson 3 - Ruby Basics (part 2)                       | http://tutorials.codebar.io/ruby/lesson3/tutorial.html      |
    | Lesson 4 - Object Oriented Ruby and Inheritance       | http://tutorials.codebar.io/ruby/lesson4/tutorial.html      |
    | Lesson 5 - Object Oriented Ruby and Inheritance (part 2)    | http://tutorials.codebar.io/ruby/lesson5/tutorial.html |
    | Installing Python                                     | http://tutorials.codebar.io/python/lesson0/tutorial.html    |
    | Lesson 1 - Strings, Integers and Floats               | http://tutorials.codebar.io/python/lesson1/tutorial.html    |
    | Lesson 2 - Playing with variables                     | http://tutorials.codebar.io/python/lesson2/tutorial.html    |
    | Lesson 3 - Lists, Tuples and Dictionaries             | http://tutorials.codebar.io/python/lesson3/tutorial.html    |
    | Lesson 4 - Fun with Functions                         | http://tutorials.codebar.io/python/lesson4/tutorial.html    |
    | Python For You and Me                                 | http://pymbook.readthedocs.io/en/latest/                    |
    | Learn Python The Hard Way                             | https://learnpythonthehardway.org/book/                     |
    | Lesson 1 - Introduction to PHP                        | http://tutorials.codebar.io/php/lesson1/tutorial.html       |
    | Lesson 1 - Introduction to the command line           | http://tutorials.codebar.io/command-line/introduction/tutorial.html      |
    | Introduction to version control                       | http://tutorials.codebar.io/version-control/introduction/tutorial.html   |
    | Introduction to the git command line                  | http://tutorials.codebar.io/version-control/command-line/tutorial.html   |
    | Codewars                                              | https://www.codewars.com/                                   |
    | Codecademy                                            | https://www.codecademy.com/                                 |
