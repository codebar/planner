# Migrating from Selenium to Playwright

**Date:** 2026-02-01
**Status:** Design

## Goals

Replace Selenium with Playwright to improve test stability, developer experience, CI performance, and future-proof the test infrastructure.

## Context

The codebar planner test suite runs 6 JavaScript-dependent feature specs using Capybara with Selenium WebDriver. Tests run in Docker containers during development and on GitHub Actions in CI.

Current state:
- Tests are rarely flaky (< 5% failure rate)
- Development uses Docker with `bin/drspec` commands
- CI runs on GitHub Actions
- Chrome driver runs headless by default, with `CHROME_HEADLESS=false` for debugging

Motivations for migration:
- Better debugging tools (Playwright Inspector, trace viewer, codegen)
- Improved test stability (blog reports 30% → 5% failure reduction)
- Modern, actively-developed tooling
- Cross-browser testing capabilities (Firefox, WebKit)

## Approach

Direct replacement of Selenium with Playwright. The small test surface (6 specs) makes gradual migration unnecessary.

## Dependencies

### Gemfile Changes

Remove:
```ruby
gem 'selenium-webdriver'
```

Add:
```ruby
gem 'capybara-playwright-driver'
```

The `capybara-playwright-driver` gem includes `playwright-ruby-client` as a dependency.

### Browser Installation

Playwright requires browser binaries installed separately from the gem. Use npx to install without modifying package.json:

```bash
npx --yes playwright@1.49.1 install --with-deps chromium
```

The version should match the `playwright-ruby-client` gem's expectations (check `Playwright::COMPATIBLE_PLAYWRIGHT_VERSION`). The `--with-deps` flag installs required system libraries.

**Docker:** Add to Dockerfile or setup script after installing Node.js.

**Host machine:** Developers run once to install to `~/.cache/ms-playwright`.

## Configuration

### Capybara Driver (spec/support/capybara.rb)

Replace current Chrome driver with:

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

**Environment variables:**
- `PLAYWRIGHT_BROWSER`: chromium (default), firefox, or webkit
- `PLAYWRIGHT_HEADLESS`: false to show visible browser for debugging

**Why these defaults:**
- Chromium matches current Chrome usage
- Headless by default for speed and CI compatibility
- User can override for debugging: `PLAYWRIGHT_HEADLESS=false bin/drspec spec/...`

**Advanced debugging:**
- Playwright Inspector: `PWDEBUG=1 bin/drspec spec/...`
- Trace viewer: enable in driver options, view after test runs

### Screenshot Logic (spec/spec_helper.rb:105)

Update driver check:

```ruby
if example.exception && defined?(page) && Capybara.current_driver == :playwright
```

## Docker Integration

### Dockerfile Changes

Add Node.js and Playwright installation:

```dockerfile
# Install Node.js if not present
RUN apt-get update && apt-get install -y nodejs npm

# Install Playwright browsers
RUN npx --yes playwright@1.49.1 install --with-deps chromium
```

### Script Updates

No changes needed to `bin/drspec`, `bin/dstart`, or other Docker scripts. The migration is transparent to these tools.

The `bin/dup` (initial setup) script should include the Playwright installation step.

## CI Configuration (GitHub Actions)

Update workflow to cache Playwright browsers:

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

- name: Run tests
  env:
    PLAYWRIGHT_HEADLESS: true
  run: bundle exec rspec
```

**Cache strategy:**
- Store browsers at `~/.cache/ms-playwright` (~100MB)
- On cache miss: install browsers and dependencies (slower first run)
- On cache hit: install only system dependencies (fast)
- Expect ~20 seconds overhead for cache setup

## Test Code Changes

Based on the referenced blog post, expect these changes:

### 1. Confirm Dialogs

If tests use `accept_confirm` or `dismiss_confirm`, they may require block syntax:

```ruby
# May need to change from:
accept_confirm
click_button "Delete"

# To:
accept_confirm do
  click_button "Delete"
end
```

### 2. XML/HTML Whitespace

Playwright normalizes whitespace differently than Selenium. Tests checking exact text with extra spaces may need adjustment. This is rare.

### 3. Console Warnings

Playwright may output non-fatal browser console errors that Selenium ignored. These won't fail tests but may clutter output. Can be suppressed if needed.

### 4. Chosen.js Dropdowns

The `select_from_chosen` helper in `spec/support/select_from_chosen.rb` interacts with Chosen.js dropdowns. This is the highest-risk area for compatibility issues.

## Affected Tests

Six specs use `js: true`:

1. `spec/features/viewing_pages_spec.rb:16` - 404 page test
2. `spec/features/accepting_terms_and_conditions_spec.rb:19` - Reading ToC content
3. `spec/features/member_feedback_spec.rb:60` - Form submission with success message
4. `spec/features/admin/add_user_to_workshop_spec.rb` - Workshop user management (uses Chosen.js)
5. `spec/features/admin/members_spec.rb:62` - Unsubscribe member from group
6. `spec/features/admin/manage_workshop_attendances_spec.rb:44` - RSVP student to workshop

Pay special attention to tests 4-6, which likely use the `select_from_chosen` helper.

## Validation Plan

### Phase 1: Setup (Day 1)
1. Update Gemfile, run `bundle install`
2. Install Playwright browsers in Docker container
3. Install Playwright browsers on host machine
4. Update `spec/support/capybara.rb`
5. Update `spec_helper.rb` screenshot logic
6. Run one simple JavaScript test to verify basic functionality

### Phase 2: Test Suite (Days 1-2)
1. Run all 6 JavaScript tests
2. Document failures with specific error messages
3. Fix test code issues:
   - Confirm dialog syntax
   - Whitespace expectations
   - Chosen.js interactions
4. Verify screenshots work on failures
5. All tests pass reliably

### Phase 3: Developer Experience (Day 2)
1. Test `bin/drspec` in Docker
2. Test running specs on host machine
3. Verify `PLAYWRIGHT_HEADLESS=false` opens visible browser
4. Test Playwright Inspector: `PWDEBUG=1 bin/drspec spec/...`
5. Test cross-browser: `PLAYWRIGHT_BROWSER=firefox bin/drspec spec/...`

### Phase 4: CI Integration (Days 2-3)
1. Update GitHub Actions workflow
2. Run full CI build
3. Verify browser caching works
4. Compare CI performance to baseline
5. Run several times to validate stability

## Success Criteria

- All 6 JavaScript tests pass reliably
- Tests run in Docker container via `bin/drspec`
- Tests run on host machine
- Headless mode works in CI
- Visual debugging works locally with `PLAYWRIGHT_HEADLESS=false`
- CI build time acceptable (expect +20s for cache setup)
- No increase in test flakiness
- Playwright Inspector accessible via `PWDEBUG=1`

## Rollback Plan

If critical issues arise:

1. Revert Gemfile changes
2. Restore `spec/support/capybara.rb`
3. Restore `spec_helper.rb` screenshot logic
4. Commit revert

The small test surface makes rollback low-risk.

## Expected Benefits

### Developer Experience
- **Playwright Inspector** - step through tests, inspect selectors, view network activity
- **Trace viewer** - record test execution, replay failures with full context
- **Codegen** - record browser interactions to generate test code
- **Better error messages** - more actionable failure information

### Test Stability
- Auto-waiting for elements (smarter than default Capybara behavior)
- Better handling of dynamic content
- More reliable network interception
- Reported improvement: 30% → 5% failure rate

### CI/CD
- Parallel browser contexts for isolation
- Built-in video/screenshot capture
- More predictable CI runs

### Future
- Active development by Microsoft
- Multi-browser support (Chromium, Firefox, WebKit)
- Modern API design
- Growing ecosystem

## Trade-offs

### Initial Investment
- 1-2 days for migration and validation
- Learning new debugging tools
- Updating documentation

### Ongoing
- ~100MB browser cache in CI
- +20 seconds CI time (first-time setup or cache miss)
- Different browser automation implementation (Capybara abstracts most differences)

### Risks (Mitigated)
- Test breakage: LOW (only 6 tests, blog reports minimal changes needed)
- Docker complexity: LOW (straightforward npx install)
- Team learning curve: LOW (Capybara API unchanged)

## Cost-Benefit Analysis

The 1-2 day investment delivers improvements in every development cycle:
- Faster debugging of test failures
- More reliable test results
- Better tools for writing new tests
- Modern, maintained infrastructure

The small test surface (6 specs) minimizes migration risk while capturing full benefits.

## References

- [Running Rails System Tests with Playwright Instead of Selenium](https://justin.searls.co/posts/running-rails-system-tests-with-playwright-instead-of-selenium/)
- [capybara-playwright-driver gem](https://github.com/YusukeIwaki/capybara-playwright-driver)
- [Playwright for Ruby](https://github.com/YusukeIwaki/playwright-ruby-client)
