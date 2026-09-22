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

  # Search query variants, used to work around TomSelect's per-query load
  # cache (loadedSearches): a query is marked as loaded the moment its
  # debounced fetch fires, so a failed or empty fetch poisons that exact
  # query string forever and options never appear, no matter how long we
  # wait. Each variant here is a distinct cache key, and /admin/members/search
  # uses ILIKE, so it matches any of them regardless of case. The full-name
  # variants also narrow the result list, which a 3-character query may
  # truncate at 50 rows.
  def tom_select_query_variants(query)
    [query[0, 3], query, query.upcase, query.downcase].uniq
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

    # Type each query variant (first 3 characters to trigger search —
    # shouldLoad requires >= 3 — then full-name variants for recovery) and
    # wait for the matching option. Use JS to set the value and dispatch an
    # input event directly, instead of send_keys (which can race with
    # TomSelect's debounce timer in headless CI when multiple parallel
    # processes contend for CPU).
    matched = tom_select_query_variants(search_query).any? do |variant|
      type_into_tom_select(input, variant)
      wrapper.has_css?('.ts-dropdown .option', text: item_text, wait: 5)
    end
    unless matched
      raise "TomSelect never displayed an option matching #{item_text.inspect} " \
            "after #{tom_select_query_variants(search_query).size} search attempts"
    end

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
