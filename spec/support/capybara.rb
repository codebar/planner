# frozen_string_literal: true

# Capybara driver using Playwright with Chromium Headless Shell
# The headless shell is ~44% smaller than full Chromium (189MB vs 336MB)
# while maintaining full web compatibility.
# See: https://playwright.dev/docs/browsers#chromium-headless-shell

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(
    app,
    headless: ENV.fetch('PLAYWRIGHT_HEADLESS', 'true') !~ /^(false|no|0)$/i,
    browser_type: ENV.fetch('PLAYWRIGHT_BROWSER', 'chromium').to_sym
  )
end

Capybara.javascript_driver = :playwright
Capybara.default_max_wait_time = 5

# Silence Capybara server output
Capybara.server = :puma, { Silent: true }
