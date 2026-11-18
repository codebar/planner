require 'rails_helper'

RSpec.feature 'admin portal' do
  scenario 'non admin cannot access the admin portal' do
    member = Fabricate(:member)
    login(member)
    visit admin_root_path

    expect(current_url).to eq(root_url)
  end

  context 'when an admin user' do
    let(:member) { Fabricate(:member) }

    before do
      login_as_admin(member)
    end

    scenario 'can view all active chapters listed' do
      chapter = Fabricate(:chapter, name: 'Manchester')
      inactive_chapter = Fabricate(:chapter, name: 'Dormant', active: false)
      visit admin_root_path

      expect(page).to have_text(chapter.name)
      expect(page).to have_no_text(inactive_chapter.name)
    end

    scenario 'can access sponsor contacts' do
      visit admin_root_path
      click_on 'Sponsor contacts'

      expect(page).to have_text('Contacts')
      expect(page).to have_text('Sponsor Contact name Contact email Mailing list')
    end
  end
end
