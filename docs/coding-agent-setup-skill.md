# Skill: Help a contributor set up codebar planner locally

Use this skill when a user asks for help setting up the codebar planner application for local development, or when they report errors running the app, tests, or database commands.

## Context

The codebar planner is a Rails 8.1 application. Contributors range from junior to senior engineers. The recommended setup path is **native installation** (not Docker). The project uses:

- **Ruby** (version in `.ruby-version`) managed by **mise**
- **PostgreSQL** as the database
- **ImageMagick** for image processing
- **GitHub OAuth** for authentication (requires a local OAuth app)
- **Bundler** for Ruby dependencies

## Diagnostic command

The project has a built-in diagnostic command. Always run this first:

```bash
bundle exec rake setup:check
```

This command checks:
- Ruby version matches `.ruby-version`
- Bundler is installed
- PostgreSQL is installed and accepting connections
- ImageMagick is installed
- `mise.local.toml` exists and contains real GitHub OAuth credentials
- Ruby gems are installed (`bundle check`)
- Database connection works
- Development database exists and is migrated
- Test database exists and is accessible

**Interpret the output:**
- ✅ = all good, no action needed
- ⚠️ = warning, development can usually proceed but review the note
- ❌ = error, must be fixed before the app will work

Each error prints a specific fix next to it. Guide the user through those fixes.

## Common scenarios and responses

### "I just cloned the repo, what do I do?"

1. Ask what operating system they are using (macOS or Linux).
2. Run `bundle exec rake setup:check` to see what is already installed.
3. Guide them through the missing pieces using the instructions in `docs/development-setup.md`.
4. Emphasise: they must create a GitHub OAuth app and configure `mise.local.toml` before the app will start.

### "The app won't start" or "I get an error when running rails server"

1. Run `bundle exec rake setup:check`.
2. If PostgreSQL errors appear, help them start the service:
   - macOS: `brew services start postgresql`
   - Linux: `sudo service postgresql start`
3. If GitHub OAuth errors appear, walk them through creating the OAuth app at https://github.com/settings/applications/new and editing `mise.local.toml`.
4. If database errors appear, run `bundle exec rake db:create db:migrate`.
5. If dependency errors appear, run `bundle install`.

### "Tests fail"

1. Run `bundle exec rake setup:check` to confirm the test database is accessible.
2. If the test database is missing, run `bundle exec rake db:test:prepare`.
3. Run `bundle exec rspec` to get the failure output.
4. If failures are in JavaScript feature tests, suggest running with `PLAYWRIGHT_HEADLESS=false bundle exec rspec` to see the browser.
5. If failures persist after a clean setup, they may be legitimate bugs — suggest opening an issue.

### "I can't log in" or "GitHub authentication fails"

1. Check `mise.local.toml` exists and contains real (not placeholder) values.
2. Verify the GitHub OAuth app callback URL is exactly `http://localhost:3000/auth/github`.
3. Make sure they restarted their terminal after creating `mise.local.toml` so mise loads the variables.
4. Check they are visiting `http://localhost:3000` (not `https` or `127.0.0.1`).

### "db:seed fails"

1. Check `bundle exec rake setup:check` for ImageMagick.
2. If ImageMagick is missing, install it:
   - macOS: `brew install imagemagick`
   - Linux: `apt-get install imagemagick`
3. Re-run `bundle exec rake db:seed`.

### "I get a 'role does not exist' error from PostgreSQL"

PostgreSQL does not have a user matching the system username. Help them create it:

- macOS: `createuser -s $(whoami)`
- Linux: `sudo -u postgres createuser -s $(whoami)`

Then re-run `bundle exec rake db:create`.

## Principles

- **Never recommend Docker** unless the user explicitly asks for it. The project documentation has moved away from Docker as the primary path.
- **Always run `setup:check` first.** It gives concrete, actionable error messages and saves time.
- **Explain the 'why' when juniors ask.** For example, explain that mise manages Ruby versions, that PostgreSQL is the database, and that GitHub OAuth credentials are needed because the app uses GitHub for login.
- **Point to the docs.** `docs/development-setup.md` is the authoritative, detailed guide. Use it as the reference for anything not covered here.
- **Assume the user is not a senior engineer.** Use simple language, avoid jargon without explanation, and break instructions into small steps.

## Quick reference

| Problem | First check | Likely fix |
|---------|------------|------------|
| App won't start | `setup:check` | PostgreSQL not running, or missing GitHub credentials |
| Database errors | `setup:check` | `bundle exec rake db:create db:migrate` |
| Tests fail | `setup:check` | `bundle exec rake db:test:prepare` |
| Can't log in | `setup:check` | GitHub OAuth app misconfigured or `mise.local.toml` not loaded |
| Seed fails | `setup:check` | `brew install imagemagick` |
| Missing gems | `setup:check` | `bundle install` |

## Off-limits

- Do not modify `.ruby-version` or `Gemfile.lock`.
- Do not commit `mise.local.toml` (it is gitignored, but reinforce this).
- Do not suggest modifying `config/database.yml` unless there is a genuine connection issue that cannot be solved with environment variables.
