# I started with:
# https://coderwall.com/p/wdq81q/capybara-select-chosen-field-for-rspec-testing
#
# However, it was not working fully, possibly because of situations where the
# list needs to scroll to find the match.
#
# I ended up putting a few suggestions together from:
# https://gist.github.com/thijsc/1391107/2d979de6ecaec4edbea086da907c65102f3d0f7a
module SelectFromChosen
  def select_from_chosen(item_text, options)
    # Find the native <select>
    field = find_field(options[:from], :visible => false)
    field_id = field[:id]

    # Find the option value we need to select
    option = field.all('option', visible: false).find { |opt| opt.text == item_text }
    raise "Option '#{item_text}' not found in select '#{options[:from]}'" unless option
    option_value = option.value

    # Use JavaScript to set the value and trigger Chosen update
    page.execute_script <<-JS
      $('##{field_id}').val('#{option_value}').trigger('chosen:updated').trigger('change');
    JS

    # Verify it was set
    expect(page).to have_select(field_id, selected: item_text, visible: false)
  end
end
