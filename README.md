# Planner [![Gittip](http://img.shields.io/gittip/by_codebar.png)](https://www.gittip.com/by_codebar/)

A tool to help manage [codebar.io](http://codebar.io) members and events.

[![Build Status](https://travis-ci.org/codebar/planner.png?branch=master)](https://travis-ci.org/codebar/planner)
[![Coverage Status](https://coveralls.io/repos/codebar/planner/badge.png)](https://coveralls.io/r/codebar/planner)
[![Code Climate](https://codeclimate.com/github/codebar/planner.png)](https://codeclimate.com/github/codebar/planner)
[![Dependency Status](https://gemnasium.com/codebar/planner.png)](https://gemnasium.com/codebar/planner)



## Getting started

First thing you will need, is to install Ruby 2.1.5

### Using [rvm](https://rvm.io/rvm/install)

```bash
rvm install 2.1.5
```

### Using [rbenv](https://github.com/sstephenson/rbenv)

```bash
rbenv install 2.1.5
rbenv global 2.1.5
```

### Install the gems!

```bash
gem install bundler
bundle install --without production --path vendor/bundle
```

You can use the `--wihout production` flag to avoid installing the `pg` gem for PostgreSQL. You don't need it anyway on development!

### Setup the database

```bash
bundle exec rake db:create
bundle exec rake db:migrate db:test:prepare
```

### Enable GitHub authentication

Create an application at `https://github.com/settings/applications/new` with
`http://localhost:3000` as the `Homepage URL` and `http://localhost:3000/auth/github`
as the `Authorization callback URL`.

Once your development application is setup, create a file named `.env` in the root of the
application folder with the GitHub key and secret like so:

    GITHUB_KEY=YOUR_KEY
    GITHUB_SECRET=YOUR_SECRET

Note: Windows doesn't like creating a file named .env so do the following from a cmd prompt in your application folder:

    echo GITHUB_KEY=YOUR_KEY >> .env
    echo GITHUB_SECRET=YOUR_SECRET >> .env

### Generate some data!

```bash
bundle exec rake db:seed
```

### Run the tests
```bash
bundle exec rake
```

Note: JavaScript acceptance tests are relying on the [Poltegeist](https://github.com/teampoltergeist/poltergeist) driver, which requires
[PhantomJS](http://phantomjs.org). For more information about installing PhantomJS, please take a look
[here](https://github.com/teampoltergeist/poltergeist#installing-phantomjs).

### Find something to work on
You can pick one of the open [issues](https://github.com/codebar/planner/issues), fix a bug, improve the interface, refactor the code or improve test coverage!

If there is something else that you would like to work on, open an issue first so we can discuss it. We are always open to new ideas and ways of improving planner!

[Guidelines on contributing to planner](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md)
