RSpec.describe 'Add a user to an existing workshop', js: true, type: :feature do
  let(:member) {Fabricate(:member)}

  let!(:juliet) {Fabricate(:member, name: 'Juliet',  surname: 'Capulet')}
  let!(:romeo) { Fabricate(:member, name: 'Romeo', surname: 'Montague') }
  let(:workshop) {Fabricate(:workshop)}

  before do
   login_as_admin(member)
   @start_page = "/admin/workshops/#{workshop.id}"
  end

  scenario 'An admin searches and gets an exact match' do
    visit @start_page

    params = {callback_url: @start_page.to_s}.to_query
    visit "/admin/member-search?#{params}"
    fill_in 'Member Name', with: juliet.name_and_surname
    click_on 'Search'
    expect(page).to have_current_path(@start_page, ignore_query: true)
  end

  scenario 'An admin adds a member to a workshop' do
    visit @start_page

    params = {callback_url: @start_page.to_s}.to_query
    visit "/admin/member-search?#{params}"
    fill_in 'Member Name', with: 'e'
    click_on 'Search'
    expect(page).to have_current_path('/admin/member-search/index', ignore_query: true)

    expect(page).to have_content('Romeo Montague')
    expect(page).to have_unchecked_field('Romeo Montague')
    check('Romeo Montague')
    click_button'Take me back'

    expect(page).to have_current_path(@start_page, ignore_query: true)
    uri = URI.parse(page.current_url)
    params = Rack::Utils.parse_nested_query(uri.query).with_indifferent_access

    expect(params[:member_pick][:members]).to eq([romeo.id.to_s])
  end
end
