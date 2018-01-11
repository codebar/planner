# Contributing to codebar's planner

1. [Fork the repo](https://help.github.com/articles/fork-a-repo/).
2. Clone your repo.

    ```
    git clone git@github.com:USERNAME/planner.git
    cd planner
    ```

3. Setup & start the application.

    ```
    bundle
    rake db:create db:migrate db:seed
    rails server
    ```

4. Have a look around to get a feel for the app.
5. Run the tests. We only take pull requests with passing tests, and it's great to confirm that you have a clean slate.

    ```
    rake
    ```

6. Add a test for your change - unless you are refactoring or adjusting styles and documentation. If you are adding any functionality or fixing a bug, we need a test!
7. Implement your change and ensure all the tests pass.
8. Run Rubocop to ensure you are complying with the Ruby style guide. Refer to (https://rubocop.readthedocs.io/en/latest/) for cops/violation details.
    ```
    rubocop
    ```
9. Commit, with a meaningful & descriptive message - this is very important!

    ```
    git commit -m "Title for your commit" -m "A little more explanation"
    ```

10. Push to your fork and [open a pull request on Github](https://help.github.com/articles/creating-a-pull-request/) to the upstream repository.
11. Wait for comments and feedback - we usually get back super fast!

Syntax guidelines:

* No trailing whitespace. Blank lines should not have any space.
* `my_method(my_arg)` or `my_method` and _not_ `my_method( my_arg )`
* `a = b` and not `a=b`.
* Aim for 1.9 hash syntax - `{ dog: "Akira", cat: "Rocky" }` rather than `{ :dog => "Akira", :pug => "Rocky" }`
* Follow the conventions you see used in the source already.
