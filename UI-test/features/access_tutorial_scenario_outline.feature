Feature: Accessing tutorials

  Scenario Outline: Clicking on a tutorial link from  the homepage takes us to the right page with the correct tutorial title and from there we can return to the index page

    Given I am on the homepage
    And I click on the tutorials navbar link
    When I click on a tutorial <link>
    Then I am sent to a page with the correct title <title>
    And I can return to the previous page with a link


    Examples:
    | link                                                     | title                                            |
    | Getting started guide for students.                      | Setting up your computer for codebar             |
    | Lesson guide for coaches                                 | Coach's guide to tutorials                       |
    | Lesson 1 - Introducing HTML                              | HTML & CSS Lesson 1                              |
    | Lesson 2 - Introducing CSS                               | HTML & CSS Lesson 2                              |
    | Lesson 3 - Beyond the basics                             | HTML & CSS Lesson 3                              |
    | Lesson 4 - CSS, layouts and formatting                   | HTML & CSS Lesson 4                              |
    | Lesson 5 - Dive into HTML5 & CSS3                        | HTML & CSS Lesson 5                              |
    | Lesson 6 - Advanced HTML5                                | HTML Lesson 6                                    |
    | Lesson 7 - Media queries and responsive design           | HTML & CSS Lesson 7                              |
    | Lesson 1 - Introduction to JavaScript                    | Introduction to JavaScript                       |
    | Lesson 2 - Expressions, Loops and Arrays                 | Expressions, Loops and Arrays                    |
    | Lesson 3 - Introduction to jQuery                        | Introduction to jQuery                           |
    | Lesson 4 - HTTP Requests, AJAX and APIs                  | HTTP Requests, AJAX and APIs                     |
    | Lesson 5 - HTTP Requests, AJAX and APIs (part 2)         | HTTP Requests, AJAX and APIs (part 2)            |
    | Lesson 6 - Drawing in Canvas                             | Drawing in Canvas                                |
    | Lesson 7 - Introduction to Testing                       | Introduction to Testing                          |
    | Lesson 8 - Building your own app                         | Building your own app                            |
    | Lesson 1 - Introduction to Ruby                          | Introduction to Ruby                             |
    | Lesson 2 - Ruby Basics                                   | The basics                                       |
    | Lesson 3 - Ruby Basics (part 2)                          | The basics (part 2)                              |
    | Lesson 4 - Object Oriented Ruby and Inheritance          | Object Oriented Ruby and Inheritance             |
    | Lesson 5 - Object Oriented Ruby and Inheritance (part 2) | Object Oriented Ruby and Inheritance (continued) |
    | Installing Python                                        | Installation Guide                               |
    | Lesson 1 - Strings, Integers and Floats                  | Strings, Integers and Floats                     |
    | Lesson 2 - Playing with variables                        | Playing with variables                           |
    | Lesson 3 - Lists, Tuples and Dictionaries                | Lists, Tuples and Dictionaries                   |
    | Lesson 4 - Fun with Functions                            | Fun with Functions                               |
    | Lesson 1 - Introduction to PHP                           | Introduction to PHP                              |
    | Lesson 1 - Introduction to the command line              | Introduction to the command line                 |
    | Introduction to version control                          | Introduction to Version Control and git          |
    | Introduction to the git command line                     | Introduction to the Git command line             |


  Scenario Outline: Clicking on a tutorial link from  the homepage takes us to the right page with the correct tutorial title  and from there we can return to the home page

    Given I am on the homepage
    And I click on the tutorials navbar link
    When I click on a tutorial <link>
    Then I am sent to a page with the correct title <title>
    And I can return to the home page with a link


    Examples:
    | link                                                     | title                                            |
    | Getting started guide for students.                      | Setting up your computer for codebar             |
    | Lesson guide for coaches                                 | Coach's guide to tutorials                       |
    | Lesson 1 - Introducing HTML                              | HTML & CSS Lesson 1                              |
    | Lesson 2 - Introducing CSS                               | HTML & CSS Lesson 2                              |
    | Lesson 3 - Beyond the basics                             | HTML & CSS Lesson 3                              |
    | Lesson 4 - CSS, layouts and formatting                   | HTML & CSS Lesson 4                              |
    | Lesson 5 - Dive into HTML5 & CSS3                        | HTML & CSS Lesson 5                              |
    | Lesson 6 - Advanced HTML5                                | HTML Lesson 6                                    |
    | Lesson 7 - Media queries and responsive design           | HTML & CSS Lesson 7                              |
    | Lesson 1 - Introduction to JavaScript                    | Introduction to JavaScript                       |
    | Lesson 2 - Expressions, Loops and Arrays                 | Expressions, Loops and Arrays                    |
    | Lesson 3 - Introduction to jQuery                        | Introduction to jQuery                           |
    | Lesson 4 - HTTP Requests, AJAX and APIs                  | HTTP Requests, AJAX and APIs                     |
    | Lesson 5 - HTTP Requests, AJAX and APIs (part 2)         | HTTP Requests, AJAX and APIs (part 2)            |
    | Lesson 6 - Drawing in Canvas                             | Drawing in Canvas                                |
    | Lesson 7 - Introduction to Testing                       | Introduction to Testing                          |
    | Lesson 8 - Building your own app                         | Building your own app                            |
    | Lesson 1 - Introduction to Ruby                          | Introduction to Ruby                             |
    | Lesson 2 - Ruby Basics                                   | The basics                                       |
    | Lesson 3 - Ruby Basics (part 2)                          | The basics (part 2)                              |
    | Lesson 4 - Object Oriented Ruby and Inheritance          | Object Oriented Ruby and Inheritance             |
    | Lesson 5 - Object Oriented Ruby and Inheritance (part 2) | Object Oriented Ruby and Inheritance (continued) |
    | Installing Python                                        | Installation Guide                               |
    | Lesson 1 - Strings, Integers and Floats                  | Strings, Integers and Floats                     |
    | Lesson 2 - Playing with variables                        | Playing with variables                           |
    | Lesson 3 - Lists, Tuples and Dictionaries                | Lists, Tuples and Dictionaries                   |
    | Lesson 4 - Fun with Functions                            | Fun with Functions                               |
    | Lesson 1 - Introduction to PHP                           | Introduction to PHP                              |
    | Lesson 1 - Introduction to the command line              | Introduction to the command line                 |
    | Introduction to version control                          | Introduction to Version Control and git          |
    | Introduction to the git command line                     | Introduction to the Git command line             |
