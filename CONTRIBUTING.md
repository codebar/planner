# Contributing to Codebar's planner

## Quick guide:

1. Fork the repo.

2. Have a look around to get a feel for the app `bundle && rake db:create db:migrate db:seed`

3. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate: `bundle && rake`

4. Add a test for your change. Only styling, documentation and refactoring changes don't require any new tests.If you are adding functionality or fixing a bug, we need a test! Also, no need to test rails!

5. Make the test pass.

6. Commit, with a meaningul describing message. This is very important!

7. Push to your fork and submit a pull request.

8. Wait for comments or feedback - we usually get back superfast!

Syntax:

* no trailing whitespace. Blank lines should not have any space.
* my_method(my_arg) or my_method arguments but definitely not my_method( my_arg )
* a = b and not a=b.
* aim for 1.9 hash syntax - `{ dog: "Akira", cat: "Rockie" }` rather than `{ :dog => "Akira", :pug => "Rocky" }`
* follow the conventions you see used in the source already.
