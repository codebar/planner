# frozen_string_literal: true

# Helper for interacting with TomSelect dropdowns in Capybara feature tests
# Similar to select_from_chosen but for TomSelect remote data loading
module SelectFromTomSelect
  # Select an item from a TomSelect dropdown
  # @param item_text [String] The text to select
  # @param from [String, Symbol] The field ID (for documentation purposes)
  def select_from_tom_select(item_text, from: nil)
    # Wait for TomSelect to initialize - the real initialization runs via the
    # jQuery DOMContentLoaded handler in application.js, which fires after the
    # CDN script (loaded in the page head) defines the TomSelect global.
    expect(page).to have_css('.ts-wrapper', wait: 15)

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
    # Uses a generous timeout for CI environments where AJAX may be slower
    expect(page).to have_css('.ts-dropdown .option', wait: 10)

    # Click the matching option
    # Use JavaScript click to avoid element interception issues
    option = find('.ts-dropdown .option', text: item_text, match: :prefer_exact)
    page.execute_script("arguments[0].click();", option.native)
  end

  # Remove an item from a TomSelect multi-select
  # @param item_text [String] The text of the item to remove (must match exactly)
  def remove_from_tom_select(item_text)
    # Wait for TomSelect to initialize and items to be present
    expect(page).to have_css('.ts-wrapper', wait: 15)
    expect(page).to have_css('.ts-wrapper .item', text: item_text, wait: 5)

    within '.ts-wrapper' do
      find('.item', text: item_text, match: :prefer_exact).find('.remove').click
    end
  end
end

RSpec.configure do |config|
  config.include SelectFromTomSelect, type: :feature
end
