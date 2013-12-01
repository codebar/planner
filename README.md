# Planner [![Gittip](http://img.shields.io/gittip/shields.io.png)](https://www.gittip.com/by_codebar/)

A tool to help manage [codebar.io](http://codebar.io) members and events.

[![Build Status](https://travis-ci.org/codebar/planner.png?branch=master)](https://travis-ci.org/codebar/planner)
[![Coverage Status](https://coveralls.io/repos/codebar/planner/badge.png)](https://coveralls.io/r/codebar/planner)
[![Code Climate](https://codeclimate.com/github/codebar/planner.png)](https://codeclimate.com/github/codebar/planner)


## Getting started

First thing you will need, is to install Ruby 2.0.0

### Using [rvm](https://rvm.io/rvm/install)

```
rvm install 2.0.0-p353
```

### Using [rbenv](https://github.com/sstephenson/rbenv)

```
rbenv install 2.0.0-p353
rbenv global 2.0.0-p353
```

### Install the gems!

```
gem install bundler
bundle install --without production
```

_You need to user the --wihout production flag to avoid requiring the **pg** gem, and Postgres. You don't need it anyway on development!_

### Setup the database

```
bundle exec rake db:create
bundle exec rake db:migrate db:test:prepare
```

### Generate some data!

```
bundle exec rake db:seed
```

### Run the tests
```
bundle exec rake
```

### Find something to work on
You can pick one of the open [issues](https://github.com/codebar/planner/issues), fix a bug, improve the interface, refactor the code or improve test coverage!

If there is something else that you would like to work on, open an issue first so we can discuss it. We are always open to improving our application!

[Guidelines on contributing to planner](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md)

