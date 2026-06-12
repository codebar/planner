# codebar website & event planner

[![CI](https://github.com/codebar/planner/actions/workflows/ruby.yml/badge.svg)](https://github.com/codebar/planner/actions/workflows/ruby.yml)
[![Coverage Status](https://coveralls.io/repos/codebar/planner/badge.png)](https://coveralls.io/r/codebar/planner)

A tool to help manage [codebar.io](https://codebar.io) members and events.

If you are considering making a PR, please take a look at the [GitHub issues](https://github.com/codebar/planner/issues) to see if there are any new feature requirements or bugs that you maybe able to help resolve.

**Need help? [We're on Slack!](https://slack.codebar.io)**

## Getting Started

The following steps walk through getting the application running. Before you start, please check out our [contributing guidelines](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md).

1. [Clone the project](#1-clone-the-project)
2. [Enable GitHub Authentication](#2-enable-github-authentication)
3. [Install and set up the environment using docker](#3-install-and-set-up-the-environment-using-docker)
4. [Start the app](#4-start-the-app)
5. [Run the tests](#5-run-the-tests)

### 1. Clone the project

1. Navigate to your project's chosen parent directory, e.g. `cd ~/Documents/codebar`
2. [Clone the project](https://help.github.com/articles/cloning-a-repository/), e.g. `git clone git@github.com:codebar/planner.git`
3. Navigate into the project directory: `cd planner`

### 2. Enable GitHub Authentication

The application uses GitHub OAuth for user authentication. You'll need to create a new OAuth application on your GitHub account, then add the key and secret to your project's environment variables.

#### Create a new Github OAuth application

Visit [https://github.com/settings/applications/new](https://github.com/settings/applications/new) and fill out the form to create a new application. Use these field values:

| Field | Value |
| --- | --- |
| Application name | Something memorable, like 'codebar planner' |
| Homepage URL | `http://localhost:3000` |
| Application description | Something memorable, like 'Local codebar app authentication'. |
| Authorization Callback URL | `http://localhost:3000/auth/github` |

#### Add your application details to your environment variables

**Native installation (recommended):** Copy `mise.local.toml.example` to `mise.local.toml`
and fill in your GitHub key and secret:

```
cp mise.local.toml.example mise.local.toml
# Edit mise.local.toml with your values
```

Environment variables are managed by [mise](https://mise.jdx.dev). Install it
with `brew install mise` and enable `mise activate` in your shell profile.

**Docker installation:** Copy `docker-compose.override.yml.example` to
`docker-compose.override.yml` and fill in your GitHub key and secret:

```
cp docker-compose.override.yml.example docker-compose.override.yml
# Edit docker-compose.override.yml with your values
```

Docker Compose automatically merges this file — no extra configuration needed.

### 3. Install and set up the environment using docker

We recommend using Docker to install and run the application. However alternatively if you prefer, [you can install directly to your system environment instead](./native-installation-instructions.md).

Before you start, you will need to have Docker installed and running. You can [download it from the Docker website](https://docker.com/). Once downloaded, install and start the Docker application.

Run `bin/dup` to build and create the docker container. This will also set up the Rails application within the container and start the container. You will only have to run this command once. After initial setup, use `bin/dstart` to start an existing container - using `bin/dup` will recreate an existing container and reset the database.

**Note:** The Docker setup includes ImageMagick automatically. If you're using native installation, you must install ImageMagick separately (see [native-installation-instructions.md](./native-installation-instructions.md)).

### 4. Start the app

Run `bin/dserver` to start the Rails server.

*If you have previously stopped the container, you will have to first start the container using `bin/dstart`.

This should run a process which starts a server in a Docker container on your computer. This process won't finish - you'll know the server is ready when it stops doing anything and displays a message like this:
```
Rails 4.2.11 application starting in development on http://localhost:3000
```

(Optional) Note that to be able to use the page as an admin, you must first give yourself admin privileges. Make sure you have started your app and signed up as an user on your locally running app. Then run the script `bin/dadmin <your email>`.

**You can now view the app at http://localhost:3000**

You can stop the server when you're finished by typing `Ctrl + C`.

### 5. Run the tests

Run `bin/drspec` to run all the tests.

This command passes any additional arguments into `rspec` in the docker container, so you can run individual tests with `bin/drspec PATH_TO_TEST` and run a single test case in a file with `bin/drspec PATH_TO_TEST:LINE_NUMBER`

#### Running JavaScript enabled feature tests with a visible browser

There are a small number of feature tests marked with `js: true` which use
headless Chrome. These can be hard to work with without being able to see what is
actually happening in the browser. To spin up a visible browser, pass
`CHROME_HEADLESS=false` as part of the test command, for example:

```bash
CHROME_HEADLESS=false bundle exec rspec
```

Running JavaScript enabled tests with a visible browser currently doesn't work with Docker.

### Available Docker commands

- `bin/dup`: `docker-compose up --build -d --wait && rake db:drop db:create db:migrate db:seed db:test:prepare`. Rebuilds and boots up a new container, and then initialize the Rails database.
- `bin/dstart`: `docker-compose start`. Starts the existing container.
- `bin/dserver`: `docker-compose exec web make serve`. Runs the Rails server. Use this instead of `bin/drails server` to make it bind to the correct IP addresses to allow the server to be viewable outside the container.
- `drails`: `docker-compose exec web rails $@`. Runs rails within the container.
- `drspec`: `docker-compose exec web rspec $@`. Runs rspec within the container.
- `drake`: `docker-compose exec web rake $@`. Runs rake inside the container.
- `dexec`: `docker-compose exec web bash`. Runs a bash shell inside the container.
- `dadmin`: Gives the the last user (or the one with a given email) the admin role
- `bin/dstop`: `docker-compose stop`. Stops container but does not remove it
- `bin/ddown`: `docker-compose down`. Stops and destroy a container.

## Front-end framework

We use Bootstrap 5, you can find the documentation here: https://getbootstrap.com/docs/5.2/getting-started/introduction/

## Finding something to work on

You can pick one of the open [issues](https://github.com/codebar/planner/issues), fix a bug, improve the interface, refactor the code or improve test coverage!

If there is something else that you would like to work on, open an issue first so we can discuss it. We are always open to new ideas and ways of improving planner!

[Guidelines on contributing to planner](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md)
