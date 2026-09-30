# Contributing to codebar's planner

1. [Fork the repo](https://help.github.com/articles/fork-a-repo/).
2. Clone your repo.

    ```
    git clone git@github.com:USERNAME/planner.git
    cd planner
    ```

3. Setup & start the application. See the [Quick start](https://github.com/codebar/planner#quick-start) section of the README for full setup instructions (mise, PostgreSQL, ImageMagick). Once set up:

    ```
    bundle exec rails server
    ```

4. Have a look around to get a feel for the app.
5. Run the tests. We only take pull requests with passing tests, and it's great to confirm that you have a clean slate.

    ```
    bundle exec rspec
    ```

6. Add a test for your change - unless you are refactoring or adjusting styles and documentation. If you are adding any functionality or fixing a bug, we need a test!
7. Implement your change and ensure all the tests pass.
8. Run Rubocop to ensure you are complying with the Ruby style guide. Refer to (https://rubocop.readthedocs.io/en/latest/) for cops/violation details.
    ```
    bundle exec rubocop
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

## Deploys and preboot

Production runs with [Heroku preboot](https://devcenter.heroku.com/articles/preboot). New web dynos start before the old ones stop, which avoids the brief 503 window of a normal restart deploy, provided the new dynos boot successfully. Traffic switches to the new dynos about 3 minutes after the deploy completes (whether or not they boot cleanly), and the old dynos shut down then.

What this means when you deploy:

* New code starts serving about 3 minutes after the deploy. Wait for the switchover before you verify a fix on production.
* During the overlap two code versions run side by side, but only one serves traffic. `heroku ps` shows only the new dynos; the still-serving old dynos do not appear in it. Watch `heroku logs --tail` to see the old dynos shut down after the switch.
* To stop a bad dyno immediately, use `heroku ps:stop`. With preboot, a plain `heroku restart` only fully takes effect after restarts have stopped for about 3 minutes.
* A migration that cannot run against the old code needs preboot temporarily disabled: `heroku features:disable preboot`, deploy, then `heroku features:enable preboot`. See the migration guidance in `AGENTS.md`.

Only the `web` process type is affected. One-off dynos and scheduled jobs behave as before.
