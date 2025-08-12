RSpec.describe 'Add a user to an existing workshop', type: :feature do
  let(:member) {Fabricate(:member)}

  let(:juliet) {Fabricate(:member, name: 'Juliet',  surname: 'Capulet')}
  let(:romeo) {Fabricate(:member, name: 'Romeo', surname: 'Montague')}
  let(:workshop) {Fabricate(:workshop)}

  before do
   login_as_admin(member)
   @start_page = "/admin/workshops/#{workshop.id}"
  end

  scenario 'An admin searches and gets an exact match', js: true do
    visit @start_page

    params = {callback: @start_page.to_s}.to_query
    visit "/admin/member-search?#{params}"
    fill_in 'Member Name', with: juliet.name
    click_on 'Search'
    expect(current_url).to include(@start_page)
  end

  scenario 'An admin adds a member to a workshop' do

  end

  scenario 'An admin adds multiple members to a workshop' do

  end
end