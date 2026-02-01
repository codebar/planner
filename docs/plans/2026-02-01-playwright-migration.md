# Playwright Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace Selenium with Playwright for JavaScript-enabled Capybara tests.

**Architecture:** Direct swap of webdriver gem and Capybara configuration. Playwright provides better debugging tools, improved stability, and modern browser automation. Only 6 JavaScript tests affected, making this a low-risk migration.

**Tech Stack:** Ruby 3.4, Rails 7.2, RSpec, Capybara, Playwright (via capybara-playwright-driver gem), Docker, GitHub Actions

---

## Task 1: Update Gemfile Dependencies

**Files:**
- Modify: `Gemfile:110`

**Step 1: Remove selenium-webdriver, add capybara-playwright-driver**

In `Gemfile`, find the test group (around line 107-117) and make this change:

```ruby
group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'capybara-playwright-driver'  # Changed from selenium-webdriver
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 7.0'
  gem 'simplecov',      require: false
  gem 'simplecov-lcov', require: false
  gem 'timecop', '~> 0.9.10'
  gem 'webmock'
end
```

**Step 2: Install new gems**

Run: `bundle install`
Expected: Successfully installs `capybara-playwright-driver` and `playwright-ruby-client` gems

**Step 3: Check Playwright version constant**

Run: `bundle exec rails runner "puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION"`
Expected: Outputs version like "1.49.1" or similar
Note: Use this version for npx commands in later tasks

**Step 4: Commit dependency changes**

```bash
git add Gemfile Gemfile.lock
git commit -m "build: replace selenium-webdriver with capybara-playwright-driver

Switch to Playwright for JavaScript browser automation.
Provides better debugging tools and improved test stability."
```

---

## Task 2: Update Capybara Driver Configuration

**Files:**
- Modify: `spec/support/capybara.rb:1-18`

**Step 1: Replace Chrome driver with Playwright driver**

Replace the entire contents of `spec/support/capybara.rb`:

```ruby
Capybara.register_driver :playwright do |app|
  options = {
    headless: ENV.fetch('PLAYWRIGHT_HEADLESS', 'true') !~ /^(false|no|0)$/i,
    browser_type: ENV.fetch('PLAYWRIGHT_BROWSER', 'chromium').to_sym
  }

  Capybara::Playwright::Driver.new(app, options)
end

Capybara.javascript_driver = :playwright
```

**Step 2: Verify syntax**

Run: `ruby -c spec/support/capybara.rb`
Expected: "Syntax OK"

**Step 3: Commit configuration change**

```bash
git add spec/support/capybara.rb
git commit -m "test: configure Playwright as JavaScript driver

Replace Selenium Chrome driver with Playwright.
Supports chromium (default), firefox, and webkit browsers.
Headless by default, override with PLAYWRIGHT_HEADLESS=false."
```

---

## Task 3: Update Screenshot Logic

**Files:**
- Modify: `spec/spec_helper.rb:105`

**Step 1: Change driver check from :chrome to :playwright**

In `spec/spec_helper.rb` around line 105, change:

```ruby
# Before:
if example.exception && defined?(page) && Capybara.current_driver == :chrome

# After:
if example.exception && defined?(page) && Capybara.current_driver == :playwright
```

**Step 2: Verify syntax**

Run: `ruby -c spec/spec_helper.rb`
Expected: "Syntax OK"

**Step 3: Commit screenshot fix**

```bash
git add spec/spec_helper.rb
git commit -m "test: update screenshot logic for Playwright driver"
```

---

## Task 4: Install Playwright Browsers on Host Machine

**Files:**
- None (system-level installation)

**Step 1: Check Node.js is installed**

Run: `node --version`
Expected: Output like "v20.x.x" or similar
If missing: Install Node.js from https://nodejs.org/

**Step 2: Install Playwright browsers**

Use the version from Task 1, Step 3 (replace X.XX.X with actual version):

Run: `npx --yes playwright@X.XX.X install --with-deps chromium`
Expected: Downloads browser (~100MB) to `~/.cache/ms-playwright`

**Step 3: Verify installation**

Run: `ls ~/.cache/ms-playwright`
Expected: Directory exists with chromium-* subdirectory

---

## Task 5: Run First JavaScript Test

**Files:**
- Test: `spec/features/viewing_pages_spec.rb:16`

**Step 1: Run simplest JavaScript test**

Run: `bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: Test passes or shows specific Playwright-related error

**Step 2: Document any failures**

If test fails, note:
- Error message
- Stack trace
- Whether it's a test code issue or driver issue

**Step 3: Fix any issues**

Common issues and fixes:
- Missing browser: Verify Task 4 completed
- Confirm dialog syntax: Wrap in block (see design doc)
- Whitespace differences: Adjust expectations

**Step 4: Verify test passes**

Run: `bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: 1 example, 0 failures

**Step 5: Commit any test fixes**

Only if test code was modified:

```bash
git add spec/features/viewing_pages_spec.rb
git commit -m "test: fix viewing_pages_spec for Playwright compatibility"
```

---

## Task 6: Run All JavaScript Tests

**Files:**
- Test: `spec/features/accepting_terms_and_conditions_spec.rb:19`
- Test: `spec/features/member_feedback_spec.rb:60`
- Test: `spec/features/admin/add_user_to_workshop_spec.rb`
- Test: `spec/features/admin/members_spec.rb:62`
- Test: `spec/features/admin/manage_workshop_attendances_spec.rb:44`

**Step 1: Run all JavaScript tests together**

Run: `bundle exec rspec spec/features/viewing_pages_spec.rb:16 spec/features/accepting_terms_and_conditions_spec.rb:19 spec/features/member_feedback_spec.rb:60 spec/features/admin/add_user_to_workshop_spec.rb spec/features/admin/members_spec.rb:62 spec/features/admin/manage_workshop_attendances_spec.rb:44 -fd`
Expected: All pass or specific failures documented

**Step 2: Fix failing tests one by one**

For each failure:
1. Run individual test: `bundle exec rspec <path>:<line> -fd`
2. Identify issue (confirm syntax, whitespace, Chosen.js)
3. Apply fix
4. Verify test passes
5. Move to next failure

**Step 3: Pay special attention to Chosen.js tests**

Tests using `select_from_chosen` helper:
- `spec/features/admin/add_user_to_workshop_spec.rb`
- Possibly `spec/features/admin/members_spec.rb:62`
- Possibly `spec/features/admin/manage_workshop_attendances_spec.rb:44`

If Chosen.js interactions fail, may need to update `spec/support/select_from_chosen.rb` helper.

**Step 4: Run all JavaScript tests again**

Run: `bundle exec rspec spec/features/viewing_pages_spec.rb:16 spec/features/accepting_terms_and_conditions_spec.rb:19 spec/features/member_feedback_spec.rb:60 spec/features/admin/add_user_to_workshop_spec.rb spec/features/admin/members_spec.rb:62 spec/features/admin/manage_workshop_attendances_spec.rb:44 -fd`
Expected: 6 examples, 0 failures

**Step 5: Commit test fixes**

```bash
git add spec/features/
git add spec/support/select_from_chosen.rb  # If modified
git commit -m "test: fix JavaScript tests for Playwright compatibility

Update test code to work with Playwright driver:
- Adjust confirm dialog syntax where needed
- Fix Chosen.js interactions if needed
- Update whitespace expectations if needed"
```

---

## Task 7: Update Dockerfile for Playwright

**Files:**
- Modify: `Dockerfile:7`

**Step 1: Add Playwright browser installation**

In `Dockerfile`, after line 7 (after installing chromium), add:

```dockerfile
FROM ruby:3.4.7

# Default node version on apt is old. This makes sure a recent version is installed
# This step also runs apt-get update
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update
RUN apt-get install -y --force-yes build-essential libpq-dev nodejs chromium chromium-driver

# Install Playwright browsers for testing
RUN npx --yes playwright@1.49.1 install --with-deps chromium

WORKDIR /planner

COPY . ./

RUN bundle install --jobs 4
```

Note: Replace `1.49.1` with version from Task 1, Step 3

**Step 2: Rebuild Docker image**

Run: `docker compose build`
Expected: Successfully builds with Playwright installation

**Step 3: Verify Playwright works in Docker**

Run: `docker compose up -d && docker compose exec web bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: Test passes in Docker container

**Step 4: Commit Dockerfile changes**

```bash
git add Dockerfile
git commit -m "build: install Playwright browsers in Docker image

Add Playwright browser installation to Dockerfile.
Ensures JavaScript tests work in Docker environment."
```

---

## Task 8: Update bin/dup Script

**Files:**
- Modify: `bin/dup:6`

**Step 1: Add Playwright installation to setup script**

In `bin/dup`, after the database setup line, add Playwright installation:

```bash
#!/usr/bin/env bash

set -e

docker compose up --build --wait
docker compose exec web bash -c "rake db:drop db:create db:migrate db:seed db:test:prepare"
docker compose exec web bash -c "npx --yes playwright@1.49.1 install --with-deps chromium"

echo "Started."
```

Note: Replace `1.49.1` with version from Task 1, Step 3

**Step 2: Test setup script**

Run: `bin/ddown && bin/dup`
Expected: Container builds, database sets up, Playwright installs

**Step 3: Verify tests work after setup**

Run: `bin/drspec spec/features/viewing_pages_spec.rb:16`
Expected: Test passes

**Step 4: Commit script update**

```bash
git add bin/dup
git commit -m "build: install Playwright browsers in Docker setup script

Add Playwright installation to bin/dup for initial setup.
Ensures new developers have browsers installed."
```

---

## Task 9: Update GitHub Actions Workflow

**Files:**
- Modify: `.github/workflows/ruby.yml:27-49`

**Step 1: Add Playwright browser caching and installation**

In `.github/workflows/ruby.yml`, after the "Set up Ruby" step (around line 36), add:

```yaml
    - name: Cache Playwright browsers
      uses: actions/cache@v3
      id: playwright-cache
      with:
        path: ~/.cache/ms-playwright
        key: playwright-${{ runner.os }}-1.49.1

    - name: Install Playwright browsers (cache miss)
      if: steps.playwright-cache.outputs.cache-hit != 'true'
      run: npx --yes playwright@1.49.1 install --with-deps chromium

    - name: Install Playwright system deps (cache hit)
      if: steps.playwright-cache.outputs.cache-hit == 'true'
      run: npx --yes playwright@1.49.1 install-deps chromium
```

Note: Replace `1.49.1` with version from Task 1, Step 3

**Step 2: Add PLAYWRIGHT_HEADLESS to test step**

Update the "Run tests" step to include:

```yaml
    - name: Run tests
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        RAILS_ENV: test
        PLAYWRIGHT_HEADLESS: true
      run: bundle exec rake spec
```

**Step 3: Verify YAML syntax**

Run: `cat .github/workflows/ruby.yml | grep -A 20 "Cache Playwright"`
Expected: Properly formatted YAML visible

**Step 4: Commit CI changes**

```bash
git add .github/workflows/ruby.yml
git commit -m "ci: configure Playwright browser caching

Add Playwright browser installation to GitHub Actions:
- Cache browsers at ~/.cache/ms-playwright (~100MB)
- Install browsers and deps on cache miss
- Only install system deps on cache hit
- Set PLAYWRIGHT_HEADLESS=true for CI runs"
```

---

## Task 10: Validate Developer Experience

**Files:**
- None (validation only)

**Step 1: Test headless mode (default)**

Run: `bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: Test runs without opening visible browser

**Step 2: Test visible browser mode**

Run: `PLAYWRIGHT_HEADLESS=false bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: Browser window opens and test runs visibly

**Step 3: Test Playwright Inspector**

Run: `PWDEBUG=1 bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: Playwright Inspector opens, can step through test

**Step 4: Test Docker execution**

Run: `bin/drspec spec/features/viewing_pages_spec.rb:16`
Expected: Test passes in Docker container

**Step 5: Test cross-browser (optional)**

Run: `PLAYWRIGHT_BROWSER=firefox bundle exec rspec spec/features/viewing_pages_spec.rb:16 -fd`
Expected: Test runs in Firefox (if Firefox installed)
Note: Firefox not required, chromium is default

**Step 6: Document validation results**

Create a summary:
- All 6 JavaScript tests pass
- Headless mode works
- Visible browser mode works
- Playwright Inspector accessible
- Docker execution works

---

## Task 11: Run Full Test Suite

**Files:**
- None (validation only)

**Step 1: Run all tests locally**

Run: `bundle exec rake spec`
Expected: All tests pass (not just JavaScript tests)

**Step 2: Fix any unrelated test failures**

If any tests fail unrelated to Playwright:
1. Investigate failure
2. Determine if it's a pre-existing issue
3. Fix if caused by migration
4. Document if pre-existing

**Step 3: Run full test suite in Docker**

Run: `bin/drspec`
Expected: All tests pass

**Step 4: Commit any additional fixes**

Only if new issues were found and fixed:

```bash
git add <affected files>
git commit -m "test: fix test suite issues found during validation"
```

---

## Task 12: Update Documentation

**Files:**
- Modify: `CLAUDE.md:115-122`

**Step 1: Update testing section in CLAUDE.md**

In `CLAUDE.md`, find the "Testing" section (around line 115) and update:

```markdown
## Testing

- **Framework**: RSpec with Capybara for feature tests
- **JavaScript Driver**: Playwright (Chromium by default)
- **Factories**: Fabrication (not FactoryBot)
- **Test data**: Faker for generated data
- **Coverage**: SimpleCov
- **JavaScript tests**: Capybara with Playwright driver
  - Use `PLAYWRIGHT_HEADLESS=false` to debug with visible browser
  - Use `PWDEBUG=1` for Playwright Inspector (step-through debugging)
  - Use `PLAYWRIGHT_BROWSER=firefox` or `webkit` for cross-browser testing
- **Matchers**: Shoulda Matchers, RSpec Collection Matchers

Run single test: `bin/drspec spec/path/to/file_spec.rb:42`
```

**Step 2: Commit documentation update**

```bash
git add CLAUDE.md
git commit -m "docs: update testing section for Playwright

Document Playwright as JavaScript driver.
Add instructions for debugging and cross-browser testing."
```

---

## Task 13: Final Validation and Push

**Files:**
- None (validation and git operations)

**Step 1: Review all commits**

Run: `git log --oneline origin/master..HEAD`
Expected: See all commits from this migration (11-12 commits)

**Step 2: Run full test suite one final time**

Run: `bundle exec rake spec`
Expected: All tests pass

**Step 3: Check git status**

Run: `git status`
Expected: "working tree clean"

**Step 4: Push branch**

Run: `git push -u origin use-playwright`
Expected: Branch pushed to remote

**Step 5: Verify CI passes**

1. Check GitHub Actions run for pushed branch
2. Verify Playwright browser caching works
3. Verify all tests pass in CI
4. Note CI build time (expect ~20s overhead for cache)

**Step 6: Create pull request**

Title: "Replace Selenium with Playwright for JavaScript tests"

Body:
```markdown
## Summary

Migrates from Selenium to Playwright for JavaScript browser automation in feature specs.

## Changes

- Replace `selenium-webdriver` with `capybara-playwright-driver` gem
- Update Capybara driver configuration to use Playwright
- Install Playwright browsers in Docker and CI
- Fix test compatibility issues (if any)
- Update documentation

## Benefits

- Better debugging tools (Playwright Inspector, trace viewer)
- Improved test stability
- Modern, actively-developed browser automation
- Cross-browser testing support (Chromium, Firefox, WebKit)

## Testing

- All 6 JavaScript tests pass locally and in Docker
- Full test suite passes
- CI updated with browser caching

## Developer Impact

- Default behavior unchanged (headless tests)
- Use `PLAYWRIGHT_HEADLESS=false` for visible debugging
- Use `PWDEBUG=1` for Playwright Inspector
- Docker: `bin/drspec` continues to work as before

Closes #[issue number if exists]
```

---

## Success Criteria

- [ ] All 6 JavaScript tests pass reliably
- [ ] All non-JavaScript tests still pass
- [ ] Tests run in Docker via `bin/drspec`
- [ ] Tests run on host machine
- [ ] Headless mode works (default)
- [ ] Visual debugging works with `PLAYWRIGHT_HEADLESS=false`
- [ ] Playwright Inspector works with `PWDEBUG=1`
- [ ] CI passes with browser caching configured
- [ ] Documentation updated
- [ ] Pull request created

## Rollback Plan

If critical issues arise during implementation:

```bash
git reset --hard origin/master
git clean -fd
```

This will discard all changes and return to master branch state.

## Notes

- Version numbers: Replace `1.49.1` with actual version from `Playwright::COMPATIBLE_PLAYWRIGHT_VERSION`
- Chosen.js: If `select_from_chosen` helper has compatibility issues, may need updates to `spec/support/select_from_chosen.rb`
- CI time: Expect ~20 seconds overhead on first run or cache miss, negligible on cache hit
- Screenshots: Still work on test failures, saved to `spec/features/<path>:<line>.png`
