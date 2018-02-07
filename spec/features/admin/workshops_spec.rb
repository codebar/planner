require 'spec_helper'

feature 'Managing workshops' do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }
  let!(:sponsor) { Fabricate(:sponsor) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, Chapter)
  end

  scenario 'creating a new workshop' do
    visit new_admin_workshop_path

    select chapter.name
    fill_in 'Local date', with: Date.current
    fill_in 'Local time', with: '11:30'

    click_on 'Save'

    expect(page).to have_content 'Invite'
  end

  scenario 'assigning a host to a workshop' do
    workshop = Fabricate(:workshop_no_sponsor)
    visit edit_admin_workshop_path(workshop)

    select sponsor.name, from: 'workshop_host'

    click_on 'Save'

    within '#host' do
      expect(page).to have_content sponsor.name
    end
  end

  scenario 'assigning a sponsor to a workshop' do
    workshop = Fabricate(:workshop_no_sponsor)
    visit edit_admin_workshop_path(workshop)

    select sponsor.name, from: 'workshop_sponsor_ids'

    click_on 'Save'

    within '#sponsors' do
      expect(page).to have_content sponsor.name
    end
  end
end
