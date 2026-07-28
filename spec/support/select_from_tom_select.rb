# frozen_string_literal: true

# Helper for interacting with TomSelect dropdowns in Capybara feature tests
# Similar to select_from_chosen but for TomSelect remote data loading
module SelectFromTomSelect
  # Select an item from a TomSelect dropdown
  # @param item_text [String] The text to select
  # @param from [String, Symbol] The original select element ID
  def select_from_tom_select(item_text, from:)
    # Wait for the specific TomSelect to initialize - the real initialization
    # runs via the jQuery DOMContentLoaded handler in application.js, which
    # fires after the CDN script (loaded in the page head) defines the TomSelect
    # global.
    select = find("##{from}", visible: false)
    wrapper = select.find(:xpath, '..')
    expect(wrapper).to have_css('.ts-control', wait: 15)

    # Open dropdown and focus the input. The click on .ts-control opens the
    # dropdown; a second click on the input focuses it, and the explicit JS
    # focus call guards against headless CI drivers where Capybara's click alone
    # does not reliably focus the field before keys are sent.
    wrapper.find('.ts-control').click
    input = wrapper.find('.ts-control input')
    input.click
    page.execute_script('arguments[0].focus();', input.native)

    # Type first 3 characters to trigger search (shouldLoad requires >= 3)
    input.send_keys(item_text[0, 3])

    # Wait for the initial search results to load after the debounce and AJAX.
    # Uses Capybara's adaptive wait instead of a blind sleep so slow CI environments
    # get enough time while fast environments don't waste a fixed wait.
    expect(wrapper).to have_css('.ts-dropdown .option', wait: 15)

    # Type the rest if item_text is longer than 3 characters
    input.send_keys(item_text[3..]) if item_text.length > 3

    # Wait for updated results after the refined search
    expect(wrapper).to have_css('.ts-dropdown .option', text: item_text, wait: 10)

    # Click the matching option
    # Use JavaScript click to avoid element interception issues
    option = wrapper.find('.ts-dropdown .option', text: item_text, match: :prefer_exact)
    page.execute_script('arguments[0].click();', option.native)
  end

  # Remove an item from a TomSelect multi-select
  # @param item_text [String] The text of the item to remove (must match exactly)
  # @param from [String, Symbol] The original select element ID
  def remove_from_tom_select(item_text, from:)
    # Wait for the specific TomSelect to initialize and items to be present
    select = find("##{from}", visible: false)
    wrapper = select.find(:xpath, '..')
    expect(wrapper).to have_css('.ts-wrapper', wait: 15)
    expect(wrapper).to have_css('.ts-wrapper .item', text: item_text, wait: 5)

    within wrapper do
      find('.item', text: item_text, match: :prefer_exact).find('.remove').click
    end
  end
end

RSpec.configure do |config|
  config.include SelectFromTomSelect, type: :feature
end
