# RuboCop setup and roadmap to zero offenses

How RuboCop is configured, how to run it, and how to drive the offense count to zero.

## Current state

RuboCop is configured in `.rubocop.yml`. The project used to exclude `spec/` from all checks, so the suite only inspected application code. Against the whole repository, RuboCop now reports roughly:

- ~2,100 offenses across application, library, and spec files
- ~1,200 of those are autocorrectable

The largest groups are RSpec cops, Capybara matchers, string literal style, and Rails/Metrics cops.

## What we are doing now

1. **Remove the blanket `spec/` exclusion** from `.rubocop.yml`.
2. **Generate a `.rubocop_todo.yml`** that lists every existing offense file-by-file. This lets the suite pass without changing the rules.
3. **Add a RuboCop job to CI** so new offenses block the build.
4. **Add `overcommit`** as an optional pre-commit hook for developers who want fast local feedback.

The todo file is generated with:

```bash
bundle exec rubocop --auto-gen-config --auto-gen-only-exclude --no-exclude-limit
```

Use `--auto-gen-only-exclude` to avoid weakening rules (for example, raising `Metrics/MethodLength` limits). Use `--no-exclude-limit` to list every offending file instead of disabling whole cops.

Because `.rubocop.yml` already excludes some cops, we merge `Exclude` lists so the todo adds to them, not replaces them.

## Running RuboCop locally

```bash
# Check everything against the current rules and todo file
bundle exec rubocop

# Run a single cop
bundle exec rubocop --only RSpec/DescribedClass
```

## How to fix offenses incrementally

Shrink `.rubocop_todo.yml` until it can be deleted. Do this in small, review-friendly pull requests.

### Pick one thing

Pick one cop or a small group of related files. For example:

- `Style/StringLiterals` in `spec/mailers/`
- `RSpec/ContextWording` everywhere
- A single `Metrics/MethodLength` violation in `app/controllers/events_controller.rb`

Avoid mixing unrelated cops in the same PR.

### Branch and fix

```bash
git checkout -b fix/rubocop-string-literals-in-mailers
```

Fix the offenses. Prefer safe autocorrect when possible:

```bash
bundle exec rubocop -a --only Style/StringLiterals spec/mailers/
```

For unsafe autocorrections, review each change manually:

```bash
bundle exec rubocop -A --only Style/StringLiterals spec/mailers/
```

### Update the todo file

After fixing, regenerate the todo so the removed offenses disappear:

```bash
bundle exec rubocop --auto-gen-config --auto-gen-only-exclude --no-exclude-limit
```

Always pass `--auto-gen-only-exclude` and `--no-exclude-limit`. Otherwise RuboCop will raise metric limits or disable whole cops instead of listing the offending files.

Review the diff to make sure it only removes entries.

### Update configuration and docs if needed

- If a cop is now fully clean, remove its entry from `.rubocop_todo.yml`; do not leave an empty list.
- If you changed `.rubocop.yml` (for example, to relax or tighten a rule), explain why in the PR description.

### Keep the PR focused

A good RuboCop cleanup PR contains:

1. The code/test changes that fix the offense.
2. The regenerated `.rubocop_todo.yml` reflecting the cleanup.
3. Any configuration or documentation updates.

One offense or one cop per PR is ideal. Large cleanup PRs are hard to review and hide regressions.

## Pre-commit hook (optional)

`overcommit` is included in the development group of the Gemfile.

To opt in:

```bash
bundle exec overcommit --install
```

This installs hooks that run RuboCop on staged files before each commit. Large commits may take a moment because every staged file is inspected. Skip hooks temporarily with:

```bash
SKIP=RuboCop git commit -m "..."
```

To remove the hooks later:

```bash
bundle exec overcommit --uninstall
```

## CI

GitHub Actions runs `bundle exec rubocop` as a separate job on every pull request. The build is green only when the todo file and the current rules report zero offenses.

## Roadmap to zero

Open `.rubocop_todo.yml`, pick the next cop or group of files, and open a focused PR. When the file is empty, delete it and remove `inherit_from: .rubocop_todo.yml` from `.rubocop.yml`.
