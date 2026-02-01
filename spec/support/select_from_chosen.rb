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

    # Find the option matching the text
    option = field.find('option', text: item_text, visible: false)

    # Use Chosen's JavaScript API to set the value and trigger change event
    page.execute_script("$('##{field[:id]}').val('#{option.value}').trigger('change').trigger('chosen:updated')")
  end
end
