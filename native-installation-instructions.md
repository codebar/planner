# Installing Ruby/Postgres on your local environment

These are the original instructions for natively installing the app to your machine, using local installations of Ruby and Postgres. For most people, we recommend [using Docker instead](README.md).

## Contents
1. [Set up a Ruby Environment](#set-up-a-ruby-environment)
    - Option 1: Using rvm
    - Option 2: Using rbenv and ruby-build
2. [Install and run PostgreSQL](#install-and-run-postgresql)
    - Using Homebrew on a Mac
3. [Set up the database](#set-up-the-database)
    - Generate sample data
4. [Run the app](#run-the-app)
5. [Run the tests](#run-the-tests)
6. (Optional) Note that to be able to use the page as an admin, you must first give yourself admin privileges. Make sure you have started your app and signed up as an user on your locally running app. Then run this on command line: `rails runner "Member.find_by(email: '<your email>').add_role(:admin)"`.

## Set up a Ruby Environment

You will need to install Ruby 2.4.9 using RVM or rbenv.

### Option 1: Using [rvm](https://rvm.io/rvm/install)

```bash
rvm install 2.4.9
```

### Option 2: Using [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build)

```bash
rbenv install 2.4.9
rbenv shell 2.4.9
```

## Install and run PostgreSQL

[The PostgreSQL Wiki has detailed installation guides](https://wiki.postgresql.org/wiki/Detailed_installation_guides) for various platforms, but probably the simplest and most common method for Mac users is with Homebrew:

### Using [Homebrew](https://brew.sh/) on a Mac

Note: You might need to install another build of Xcode Tools (typing `brew update` in the terminal will prompt you to update the Xcode build tools).

Install Postgres:
```bash
brew update
brew install postgresql
brew services start postgresql
```

Install other dependencies:
```
brew install imagemagick
```

Install the Gems:
```bash
gem install bundler
bundle install --without production
```

## Set up the Database

Adjust `config/database.yml` as needed.

```bash
bundle exec rake db:create
bundle exec rake db:migrate db:test:prepare
```

*Note:* If you are running OSX Yosemite, you may experience a problem connecting to
Postgres. [This stackoverflow answer](http://stackoverflow.com/a/26458194/1510063) might help.

### Generate sample data

```bash
bundle exec rake db:seed
```

## Run the app

```bash
bundle exec rails server
```

### Run the tests

```bash
bundle exec rake
```
