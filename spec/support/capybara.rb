# frozen_string_literal: true

# Capybara driver using Playwright with Chromium Headless Shell
# The headless shell is ~44% smaller than full Chromium (189MB vs 336MB)
# while maintaining full web compatibility.
# See: https://playwright.dev/docs/browsers#chromium-headless-shell

Capybara.register_driver :playwright do |app|
  # Use chromium-headless-shell if available (CI), fallback to regular chromium
  # Try multiple patterns to find the headless shell executable on different platforms
  cache_dir = File.expand_path('~/.cache/ms-playwright')
  patterns = [
    'chromium_headless_shell-*/**/headless_shell',         # Linux
    'chromium_headless_shell-*/**/chrome-headless-shell',  # Mac
  ]

  headless_shell = patterns.map do |pattern|
    Dir.glob(File.join(cache_dir, pattern)).max
  end.compact.first

  executable_path = headless_shell if headless_shell && File.executable?(headless_shell)

  Capybara::Playwright::Driver.new(
    app,
    headless: ENV.fetch('PLAYWRIGHT_HEADLESS', 'true') !~ /^(false|no|0)$/i,
    browser_type: ENV.fetch('PLAYWRIGHT_BROWSER', 'chromium').to_sym,
    executablePath: executable_path
  )
end

Capybara.javascript_driver = :playwright
Capybara.default_max_wait_time = 5

# Silence Capybara server output
Capybara.server = :puma, { Silent: true }
