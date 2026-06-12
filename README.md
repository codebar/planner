# codebar website & event planner

[![CI](https://github.com/codebar/planner/actions/workflows/ruby.yml/badge.svg)](https://github.com/codebar/planner/actions/workflows/ruby.yml)
[![Coverage Status](https://coveralls.io/repos/codebar/planner/badge.png)](https://coveralls.io/r/codebar/planner)

A tool to help manage [codebar.io](https://codebar.io) members and events.

If you are considering making a PR, please take a look at the [GitHub issues](https://github.com/codebar/planner/issues) to see if there are any new feature requirements or bugs that you maybe able to help resolve.

**Need help? [We're on Slack!](https://slack.codebar.io)**

## Getting Started

Before you start, please check out our [contributing guidelines](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md).

We recommend **native installation** for local development. A full step-by-step guide is in [docs/development-setup.md](docs/development-setup.md). The quick version is below.

### Quick start

1. **Install prerequisites** (macOS or Linux):
   - [mise](https://mise.jdx.dev/) — manages Ruby and environment variables
   - [PostgreSQL](https://www.postgresql.org/) — database server
   - [ImageMagick](https://imagemagick.org/) — image processing

   On macOS with Homebrew:
   ```bash
   brew install mise postgresql imagemagick
   brew services start postgresql
   ```

2. **Clone the project**:
   ```bash
   git clone https://github.com/codebar/planner.git
   cd planner
   ```

3. **Install Ruby** (managed by mise):
   ```bash
   mise install
   ```

4. **Configure GitHub OAuth**:
   - Create a GitHub OAuth app at [https://github.com/settings/applications/new](https://github.com/settings/applications/new)
   - Authorization callback URL: `http://localhost:3000/auth/github`
   - Copy your Client ID and Client Secret into `mise.local.toml`:
     ```bash
     cp mise.local.toml.example mise.local.toml
     # Edit mise.local.toml with your real credentials
     ```

5. **Install dependencies and set up the database**:
   ```bash
   gem install bundler
   bundle install
   bundle exec rake db:create db:migrate db:test:prepare
   ```

6. **Check your environment**:
   ```bash
   bundle exec rake setup:check
   ```

7. **Start the app**:
   ```bash
   bundle exec rails server
   ```

   Visit [http://localhost:3000](http://localhost:3000).

### Run the tests

```bash
bundle exec rspec
```

Run tests in parallel for faster results:
```bash
bundle exec parallel_rspec spec/ -n 3
```

Run a single test:
```bash
bundle exec rspec spec/path/to/test_spec.rb:42
```

Run JavaScript-enabled feature tests with a visible browser:
```bash
PLAYWRIGHT_HEADLESS=false bundle exec rspec
```

### Make yourself an admin

After signing up locally, run:
```bash
bundle exec rails runner "Member.find_by(email: 'your-email@example.com').add_role(:admin)"
```

### Full setup guide

For detailed, step-by-step instructions — including troubleshooting, Linux-specific steps, and explanations of what each tool does — see [docs/development-setup.md](docs/development-setup.md).

---

## Docker (not recommended)

A Docker setup exists but is **not recommended** for local development. It is slower, harder to debug, and does not support running JavaScript feature tests with a visible browser.

If you prefer Docker, see the commands in `bin/d*`:

| Command | What it does |
|---------|-------------|
| `bin/dup` | Build and start a new container (also resets the database) |
| `bin/dstart` | Start an existing container |
| `bin/dserver` | Run the Rails server inside the container |
| `bin/drspec` | Run the test suite inside the container |
| `bin/drake` | Run rake inside the container |
| `bin/dexec` | Open a shell inside the container |
| `bin/dstop` | Stop the container |
| `bin/ddown` | Stop and remove the container |

---

## Front-end framework

We use Bootstrap 5. Documentation: https://getbootstrap.com/docs/5.2/getting-started/introduction/

## Finding something to work on

You can pick one of the open [issues](https://github.com/codebar/planner/issues), fix a bug, improve the interface, refactor the code or improve test coverage!

If there is something else that you would like to work on, open an issue first so we can discuss it. We are always open to new ideas and ways of improving planner!

[Guidelines on contributing to planner](https://github.com/codebar/planner/blob/master/CONTRIBUTING.md)
