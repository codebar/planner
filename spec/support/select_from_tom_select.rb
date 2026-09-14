# frozen_string_literal: true

# Helper for interacting with TomSelect dropdowns in Capybara feature tests
# Similar to select_from_chosen but for TomSelect remote data loading
module SelectFromTomSelect
  # Search query for a display name. full_name includes pronouns, e.g.
  # "Jane Doe (she/her)", but /admin/members/search only matches
  # CONCAT(name, ' ', surname) and email, so the parenthetical must go.
  def tom_select_search_query(item_text)
    item_text.sub(/\s*\([^)]*\)\z/, '')
  end

  def type_into_tom_select(input, text)
    page.execute_script(
      "arguments[0].value = arguments[1]; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));",
      input.native, text
    )
  end

  # Select an item from a TomSelect dropdown
  # @param item_text [String] The text to select
  # @param from [String, Symbol] The original select element ID
  def select_from_tom_select(item_text, from:)
    search_query = tom_select_search_query(item_text)
    # Wait for the specific TomSelect to initialize - the real initialization
    # runs via the jQuery DOMContentLoaded handler in application.js, which
    # fires after the CDN script (loaded in the page head) defines the TomSelect
    # global.
    select = find("##{from}", visible: false)
    wrapper = select.find(:xpath, '..')
    expect(wrapper).to have_css('.ts-wrapper', wait: 15)
    expect(wrapper).to have_css('.ts-control', wait: 15)

    # Open the dropdown by clicking the control
    wrapper.find('.ts-control').click
    input = wrapper.find('.ts-control input')

    # Focus the input explicitly; in headless CI the click above does not always
    # move focus to the textbox before we dispatch the input event.
    page.execute_script('arguments[0].focus();', input.native)

    # Type first 3 characters to trigger search (shouldLoad requires >= 3).
    # Use JS to set the value and dispatch an input event directly, instead of
    # send_keys (which can race with TomSelect's debounce timer in headless CI
    # when multiple parallel processes contend for CPU).
    type_into_tom_select(input, search_query[0, 3])

    # Wait briefly for the initial 3-character search results after the
    # debounce and AJAX. TomSelect caches loads per query (loadedSearches), so
    # a failed or empty fetch poisons that query forever and options never
    # appear no matter how long we wait. Retype the full name as a fresh query
    # (new cache key, new fetch) instead of waiting it out.
    if wrapper.has_css?('.ts-dropdown .option', wait: 5)
      # Refine the search to the rest of the name if the query is longer
      # than 3 characters
      type_into_tom_select(input, search_query[3..]) if search_query.length > 3
    else
      # A 3-char query is identical to the failed query, so the retry must
      # differ to get a fresh cache key (ILIKE search is case-insensitive)
      retry_query = search_query.length > 3 ? search_query : search_query.upcase
      type_into_tom_select(input, retry_query)
    end

    # Wait for the matching option after the refined or retried search
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
