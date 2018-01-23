# Planner [![Gittip](http://img.shields.io/gittip/by_codebar.png)](https://www.gittip.com/by_codebar/)

A tool to help manage [codebar.io](http://codebar.io) members and events.

[![Build Status](https://travis-ci.org/codebar/planner.png?branch=master)](https://travis-ci.org/codebar/planner)
[![Coverage Status](https://coveralls.io/repos/codebar/planner/badge.png)](https://coveralls.io/r/codebar/planner)
[![Code Climate](https://codeclimate.com/github/codebar/planner.png)](https://codeclimate.com/github/codebar/planner)
[![Dependency Status](https://gemnasium.com/codebar/planner.png)](https://gemnasium.com/codebar/planner)

If you are considering making a PR, please take a look at the Waffle board to see if someone else has already started work on an existing issue.

#### [Waffle board](https://waffle.io/codebar/planner)

#### [We're on Slack!](https://codebar-slack.herokuapp.com)


## Getting Started

The following steps walk through getting the application running. For contributing guidelines see [here](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md).

### Setting up a Ruby Environment

You will need to install Ruby 2.4.2 using RVM or rbenv.

#### Using [rvm](https://rvm.io/rvm/install)

```bash
rvm install 2.4.2
```

#### Using [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build)

```bash
rbenv install 2.4.2
rbenv global 2.4.2
```

### Install and run PostgreSQL
[The PostgreSQL Wiki has detailed installation guides](https://wiki.postgresql.org/wiki/Detailed_installation_guides) for various platforms, but probably the simplest and most common method for Mac users is with Homebrew:

#### Using [Homebrew](https://brew.sh/) on a Mac
Note: You might need to install another build of Xcode Tools (typing `brew update` in the terminal will prompt you to update the Xcode build tools).
```bash
brew update
brew install postgresql
brew services start postgresql
```

### Install the Gems!

```bash
gem install bundler
bundle install --without production
```

### Setup the Database

Adjust `config/database.yml` as needed.

```bash
bundle exec rake db:create
bundle exec rake db:migrate db:test:prepare
```

*Note:* If you are running OSX Yosemite, you may experience a problem connecting to
Postgres. [This stackoverflow answer](http://stackoverflow.com/a/26458194/1510063) might help.

### Enable GitHub Authentication

The application uses GitHub OAuth for user authentication.

#### Create a GitHub application

Using these field values:

| Field | Value |
| --- | --- |
| Homepage URL | `http://localhost:3000` |
| Authorization Callback URL | `http://localhost:3000/auth/github` |

Create an application at [https://github.com/settings/applications/new](https://github.com/settings/applications/new).

#### Add your application details to your environment

Create a file named `.env` in the root of the application folder (`touch .env`)
with the GitHub key and secret like so:

    GITHUB_KEY=YOUR_KEY
    GITHUB_SECRET=YOUR_SECRET

*Note:* Windows doesn't like creating a file named `.env` so do the following
from a cmd prompt in your application folder:

    echo GITHUB_KEY=YOUR_KEY >> .env
    echo GITHUB_SECRET=YOUR_SECRET >> .env

### Generate some sample data

```bash
bundle exec rake db:seed
```

### Run the app

```bash
bundle exec rails server
```

### Run the tests

```bash
bundle exec rake
```

*Note:* JavaScript acceptance tests are relying on the [Poltergeist](https://github.com/teampoltergeist/poltergeist) driver, which requires
[PhantomJS](http://phantomjs.org). For more information about installing PhantomJS, please take a look
[here](https://github.com/teampoltergeist/poltergeist#installing-phantomjs).

## Front-end framework

We use Foundation at version 5.5.3, you can find the documentation here: http://foundation.zurb.com/sites/docs/v/5.5.3/

## Finding something to work on
You can pick one of the open [issues](https://github.com/codebar/planner/issues), fix a bug, improve the interface, refactor the code or improve test coverage!

If there is something else that you would like to work on, open an issue first so we can discuss it. We are always open to new ideas and ways of improving planner!

[Guidelines on contributing to planner](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md)

## UI Testing

This website has been tested on a localhost:3000. The purpose of these tests was to ensure the user interface of the website functioned as expected.

To write and run these tests, we used Cucumber to maximise readability. The Gherkin syntax allowed us to write tests that made sense as to what was being tested at the time of writing and checking.

Documentation for Cucumber can be found here: https://cucumber.io/


### Tests Written

 We have written tests based on the likelihood of a user using the path. We have used some decision tables in the tests, this allowed some links/buttons/areas to be covered faster than individually testing the link.
 The language used to write the methods for the tests have been written in ruby 2.4.2


### Running Tests

To run the tests written:
  - Go to planner location in your terminal.
  - Change directory to the UI-test folder.
  - type in:
   ```bash
   cucumber
   ```
  - When a window appears on your taskbar, open it to watch the tests run on the website, or watch the terminal to see which tests are being run.
  - To run an individual test file instead of all the .feature files at once, type in:
  ```bash
  cucumber features/sign_in_scenario_outline.feature
  ```
  *'sign_in_scenario_outline.feature' is an example*


### Writing New Tests

To create a new test, firstly make sure that the new test  has not been written already and is in the feature folder or step_defs folder. The title of each file describes the function of the test.

To write a new test, create a file with and title it with the function of the test. After the description, label it scenario outline and the type is a .feature file.
*sign_in_scenario_outline.feature as an example*

To write this file, follow the typical structure of a cucumber feature file which can be found in the documentation online, or use any other feature file as a template.

After writing the feature file and saving it, go to the terminal to create a step definitions template.

Simply type:
```bash
cucumber features/# example_scenario_outline.feature
```

This will output the steps for the test in yellow in the terminal. Copy these steps and go back into your IDE.

Add a new step_defs file to the step_definitions folder. Again the file should describe the function of the test, followed by step_defs.rb. Paste the steps in to this file. In the pages folder, create a new file that will be linked to your new step_defs file and (following the existing format of method files) write out your new methods. Don't forget to add your new method file to the codebar_site.rb file.

Go back in to your step_defs file and add in the relevant functions to run the tests. By following some of the existing step_defs files write out your tests step by step.

Once you have completed this, go back to your terminal and run:
```bash
cucumber features/# your_new_file_scenario_outline.feature
```
Make sure that all the tests pass. If they do, run:
```bash
cucumber
```
To make sure that the tests pass along side all the other existing tests.

__Reading Tests__

A test that fails will be displayed in <span style=color:red>Red</span> text, with a short description of the failure and its location.

A test that passes will be displayed in <span style=color:green>Green</span> text with no description.

A pending test will appear in <span style=color:yellow>Yellow</span>.

And a skipped test will appear <span style=color:blue>Blue</span>.
