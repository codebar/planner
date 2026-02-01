Capybara.register_driver :playwright do |app|
  options = {
    headless: ENV.fetch('PLAYWRIGHT_HEADLESS', 'true') !~ /^(false|no|0)$/i,
    browser_type: ENV.fetch('PLAYWRIGHT_BROWSER', 'chromium').to_sym
  }

  Capybara::Playwright::Driver.new(app, options)
end

Capybara.javascript_driver = :playwright
Capybara.default_max_wait_time = 5

# Silence Capybara server output
Capybara.server = :puma, { Silent: true }
