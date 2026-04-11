# frozen_string_literal: true

# Helper for interacting with TomSelect dropdowns in Capybara feature tests
# Similar to select_from_chosen but for TomSelect remote data loading
module SelectFromTomSelect
  # Select an item from a TomSelect dropdown
  # @param item_text [String] The text to select
  # @param from [String, Symbol] The field ID (for documentation purposes)
  def select_from_tom_select(item_text, from: nil)
    # Wait for TomSelect to initialize
    expect(page).to have_css('.ts-wrapper', wait: 5)

    # Open dropdown and type search query
    find('.ts-control').click
    input = find('.ts-control input')

    # Type first 3 characters to trigger search (shouldLoad requires >= 3)
    input.send_keys(item_text[0, 3])

    # Wait for debounce (300ms) and network request
    sleep 0.5

    # Type the rest if item_text is longer than 3 characters
    input.send_keys(item_text[3..]) if item_text.length > 3

    # Wait for results (includes debounce + network)
    expect(page).to have_css('.ts-dropdown .option', wait: 5)

    # Click the matching option
    find('.ts-dropdown .option', text: item_text, match: :prefer_exact).click
  end
end

RSpec.configure do |config|
  config.include SelectFromTomSelect, type: :feature
end
