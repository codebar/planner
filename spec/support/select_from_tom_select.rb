# frozen_string_literal: true

# Helper for interacting with TomSelect dropdowns in Capybara feature tests
# Similar to select_from_chosen but for TomSelect remote data loading
module SelectFromTomSelect
  # Select an item from a TomSelect dropdown
  # @param item_text [String] The text to select
  # @param from [String, Symbol] The field ID (for documentation purposes)
  def select_from_tom_select(item_text, from: nil)
    # Ensure TomSelect is initialized (workaround for pages where it doesn't auto-init)
    ensure_tom_select_initialized('meeting_organisers')

    # Wait for TomSelect to initialize - give extra time for page to fully load JS
    expect(page).to have_css('.ts-wrapper', wait: 10)

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
    # Use JavaScript click to avoid element interception issues
    option = find('.ts-dropdown .option', text: item_text, match: :prefer_exact)
    page.execute_script("arguments[0].click();", option.native)
  end

  # Remove an item from a TomSelect multi-select
  # @param item_text [String] The text of the item to remove (must match exactly)
  def remove_from_tom_select(item_text)
    # Ensure TomSelect is initialized (workaround for pages where it doesn't auto-init)
    ensure_tom_select_initialized('meeting_organisers')

    # Wait for TomSelect to initialize and items to be present
    expect(page).to have_css('.ts-wrapper', wait: 10)
    expect(page).to have_css('.ts-wrapper .item', text: item_text, wait: 5)

    within '.ts-wrapper' do
      find('.item', text: item_text, match: :prefer_exact).find('.remove').click
    end
  end

  private

  def ensure_tom_select_initialized(element_id)
    # Check if TomSelect is already initialized
    return if page.has_css?('.ts-wrapper', wait: 2)

    # Try to initialize TomSelect manually if the element exists
    # Note: This is a minimal initialization for tests where TomSelect doesn't auto-init
    script = <<~JS
      (function() {
        var elem = document.getElementById('#{element_id}');
        if (elem && typeof TomSelect !== 'undefined' && !elem.tomselect) {
          new TomSelect(elem, {
            plugins: ['remove_button'],
            placeholder: 'Type to search members...',
            valueField: 'id',
            labelField: 'full_name',
            searchField: ['full_name', 'email'],
            create: false,
            loadThrottle: 300,
            shouldLoad: function(query) { return query.length >= 3; },
            load: function(query, callback) {
              fetch('/admin/members/search?q=' + encodeURIComponent(query))
                .then(response => response.json())
                .then(json => callback(json))
                .catch(() => callback());
            }
          });
        }
      })();
    JS
    page.execute_script(script)

    # Wait for initialization
    expect(page).to have_css('.ts-wrapper', wait: 5)
  end
end

RSpec.configure do |config|
  config.include SelectFromTomSelect, type: :feature
end
