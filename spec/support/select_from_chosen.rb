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

    # Open the Chosen dialog
    find("##{field[:id]}_chosen").click

    # On the search input, type the string we're looking for and press Enter
    within field.sibling('.chosen-container') do
      input = find("input").native
      input.send_keys(item_text)
      input.send_key(:return)
    end
  end
end
