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

## Getting Started Through Docker

You will need to have Docker installed, https://docker.com/

The current Dockerfile and docker-compose were closely copied from the guide: https://docs.docker.com/compose/rails/

1. Clone the project.
2. Run `docker-compose build` to build a docker environment.
3. Run `docker-compose run web rake db:create db:migrate db:seed` to create, migrate and seed the main database
4. Run `docker-compose up` to start the app.


### Setting up a Ruby Environment

You will need to install Ruby 2.3.3 using RVM or rbenv.

#### Using [rvm](https://rvm.io/rvm/install)

```bash
rvm install 2.3.3
```

#### Using [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build)

```bash
rbenv install 2.3.3
rbenv global 2.3.3
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

## Finding something to work on
You can pick one of the open [issues](https://github.com/codebar/planner/issues), fix a bug, improve the interface, refactor the code or improve test coverage!

If there is something else that you would like to work on, open an issue first so we can discuss it. We are always open to new ideas and ways of improving planner!

[Guidelines on contributing to planner](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md)
