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
