# Development Setup Guide

This guide walks you through setting up the codebar planner application on your local machine. It is written for contributors of all experience levels — you do not need to be a senior engineer to follow it.

**What you will do:**
1. Install the tools the application needs (Ruby, PostgreSQL, etc.)
2. Get the code
3. Configure GitHub login for the app
4. Create the database and install dependencies
5. Start the application and run the tests

**What this application is:**
A [Ruby on Rails](https://rubyonrails.org/) web application that manages codebar members, workshops, events, and RSVPs. It uses [PostgreSQL](https://www.postgresql.org/) for data storage and [Bootstrap 5](https://getbootstrap.com/) for the front end.

---

## Prerequisites

You need a computer running **macOS** or **Linux** (including WSL on Windows). The commands below assume a [Unix shell](https://en.wikipedia.org/wiki/Unix_shell) (Terminal on macOS, or any terminal emulator on Linux).

You will need these tools installed:

| Tool | What it does | How to check if you have it |
|------|-------------|----------------------------|
| [Git](https://git-scm.com/) | Downloads the code | `git --version` |
| [Homebrew](https://brew.sh/) (macOS) or your distro's package manager (Linux) | Installs other tools | `brew --version` (macOS) |
| [mise](https://mise.jdx.dev/) | Manages Ruby versions and environment variables | `mise --version` |
| [PostgreSQL](https://www.postgresql.org/) | Database server | `psql --version` |
| [ImageMagick](https://imagemagick.org/) | Image processing (used for member avatars) | `convert --version` |

If any of these are missing, follow the installation instructions below for your operating system.

---

## macOS Setup

### Step 1: Install Xcode Command Line Tools

These are free developer tools from Apple. You need them before installing anything else.

```bash
xcode-select --install
```

If a dialog appears, click **Install**. If it says they are already installed, you are good to go.

### Step 2: Install Homebrew

Homebrew is a package manager for macOS — it makes installing software much easier.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the instructions it prints. After installation, you may need to add Homebrew to your shell path.

### Step 3: Install mise

mise manages which version of Ruby this project uses. This is important because different projects need different Ruby versions.

```bash
brew install mise
```

After installing, you need to activate it in your shell. Add this to your shell profile file (`~/.zshrc` if you use the default macOS shell, or `~/.bashrc` if you use Bash):

```bash
eval "$(mise activate zsh)"
```

Then reload your shell:

```bash
source ~/.zshrc
```

### Step 4: Install PostgreSQL

```bash
brew install postgresql
brew services start postgresql
```

`brew services start` makes PostgreSQL run automatically whenever you start your computer.

By default, PostgreSQL on macOS creates a database user with your computer username and no password. This usually "just works" with Rails applications.

### Step 5: Install ImageMagick

```bash
brew install imagemagick
```

### Step 6: Install Ruby

mise reads the `.ruby-version` file in the project and installs the correct version automatically.

```bash
mise install
```

This may take a few minutes. On Apple Silicon (M1/M2/M3/M4) Macs, you may see a compilation warning about `ffi` — this is normal and the installation will still succeed.

---

## Linux Setup

These instructions are for Debian/Ubuntu-based distributions. If you use a different distribution, use your distribution's equivalent package manager.

### Step 1: Install system dependencies

```bash
sudo apt-get update
sudo apt-get install -y git curl build-essential libpq-dev libsqlite3-dev nodejs imagemagick
```

`libpq-dev` is required for the Ruby gem that connects to PostgreSQL.

### Step 2: Install PostgreSQL

```bash
sudo apt-get install -y postgresql postgresql-contrib
sudo service postgresql start
```

You may need to create a PostgreSQL user that matches your Linux username:

```bash
sudo -u postgres createuser -s $(whoami)
```

### Step 3: Install mise

```bash
curl https://mise.run | sh
```

Add mise to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.bashrc
source ~/.bashrc
```

### Step 4: Install Ruby

```bash
mise install
```

---

## Clone the project

```bash
# Navigate to where you keep your code projects
cd ~/Documents

# Clone the repository
git clone https://github.com/codebar/planner.git

# Enter the project directory
cd planner
```

---

## Configure GitHub Authentication

The application uses GitHub OAuth for user login. You need to create a GitHub OAuth application and tell the code about its credentials.

### 1. Create a GitHub OAuth app

1. Go to [https://github.com/settings/applications/new](https://github.com/settings/applications/new)
2. Fill in the form:

| Field | Value |
|-------|-------|
| Application name | `codebar planner local` (or anything memorable) |
| Homepage URL | `http://localhost:3000` |
| Application description | `Local development for codebar planner` |
| Authorization callback URL | `http://localhost:3000/auth/github` |

3. Click **Register application**
4. You will see a **Client ID** and a **Client Secret**. Keep this page open — you will copy these into the project.

### 2. Add credentials to the project

```bash
cp mise.local.toml.example mise.local.toml
```

Open `mise.local.toml` in your text editor and replace the placeholder values:

```toml
[env]
GITHUB_KEY = "your_github_oauth_client_id"
GITHUB_SECRET = "your_github_oauth_client_secret"
```

Use the real values from your GitHub OAuth app page.

**Why this file?** mise automatically loads environment variables from `mise.local.toml`. This keeps secrets out of the code and lets each developer have their own settings.

**Important:** `mise.local.toml` is ignored by Git, so your credentials will never be accidentally committed.

---

## Install Ruby dependencies

```bash
gem install bundler
bundle install
```

`bundler` is Ruby's dependency manager. It reads `Gemfile` and installs all the Ruby libraries the application needs.

This step may take a few minutes the first time.

---

## Set up the database

```bash
bundle exec rake db:create db:migrate db:test:prepare
```

This command does three things:
- `db:create` — creates the development and test databases in PostgreSQL
- `db:migrate` — runs database migrations (sets up tables, columns, indexes)
- `db:test:prepare` — makes sure the test database is ready for running tests

---

## Run the diagnostic check

We provide a built-in command that checks your environment and tells you if anything is missing:

```bash
bundle exec rake setup:check
```

If this prints all green checkmarks, you are ready to go. If it reports any errors, follow the suggestions it prints.

---

## Start the application

```bash
bundle exec rails server
```

You will see output ending with something like:

```
=> Booting Puma
=> Rails 8.1.2 application starting in development
=> Run `bin/rails server --help` for more startup options
  Please visit https://localhost:3000
```

Open [http://localhost:3000](http://localhost:3000) in your web browser.

**To stop the server**, press `Ctrl + C` in the terminal.

---

## Run the tests

```bash
bundle exec rspec
```

This runs the full test suite. It should take a few minutes and report something like:

```
1000+ examples, 0 failures
```

If you see any failures, please check that your setup matches this guide, then ask in the [codebar Slack](https://slack.codebar.io).

### Run a single test file

```bash
bundle exec rspec spec/models/member_spec.rb
```

### Run a specific test

```bash
bundle exec rspec spec/models/member_spec.rb:42
```

### Run tests in parallel (faster)

```bash
bundle exec parallel_rspec spec/ -n 3
```

### Run JavaScript-enabled feature tests with a visible browser

Some tests use a headless browser. To see the browser:

```bash
PLAYWRIGHT_HEADLESS=false bundle exec rspec
```

---

## Optional: Add sample data

To populate the database with fake workshops, members, and events for local testing:

```bash
bundle exec rake db:seed
```

---

## Make yourself an admin

After signing up in your local app, you can give yourself admin privileges:

```bash
bundle exec rails runner "Member.find_by(email: 'your-email@example.com').add_role(:admin)"
```

Replace `your-email@example.com` with the email you used when signing up locally.

---

## Common problems

### "psql: command not found"

PostgreSQL is not installed or not in your PATH. Reinstall it and make sure your terminal is restarted after installation.

### "Could not connect to server: Connection refused"

PostgreSQL is not running. Start it:
- macOS: `brew services start postgresql`
- Linux: `sudo service postgresql start`

### "FATAL: database 'planner_development' does not exist"

Run `bundle exec rake db:create db:migrate`.

### "Bundler::GemNotFound" or "Could not find gem"

Run `bundle install` again.

### "role does not exist" when creating the database

PostgreSQL does not have a user matching your computer username. Create it:

```bash
# macOS (usually not needed)
createuser -s $(whoami)

# Linux
sudo -u postgres createuser -s $(whoami)
```

### GitHub login fails with "missing credentials"

Check that `mise.local.toml` exists and contains real values (not the placeholders). Then restart your terminal so mise loads the new variables.

---

## Need help?

- [codebar Slack](https://slack.codebar.io) — the #planner channel is the best place to ask
- [GitHub issues](https://github.com/codebar/planner/issues) — for bugs or improvements to this guide

---

## Docker (not recommended for most contributors)

A Docker setup exists in this repository, but it is **not the recommended path** for local development. It is slower, harder to debug, and does not support running JavaScript feature tests with a visible browser.

If you still prefer Docker, see the Docker commands in `bin/d*`. However, the instructions above are the supported and recommended path.
