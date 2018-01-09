require 'spec_helper'

feature 'admin portal' do
  scenario 'non admin cannot access the admin portal' do
    member = Fabricate(:member)
    login(member)
    visit admin_root_path

    expect(current_url).to eq(root_url)
  end

  context 'an admin user' do
    let(:member) { Fabricate(:member) }

    before do
      login_as_admin(member)
    end

    scenario 'can view all active chapters listed' do
      chapter = Fabricate(:chapter_with_groups)
      inactive_chapter = Fabricate(:chapter_with_groups, active: false)
      visit admin_root_path

      chapter.groups.each do |group|
        expect(page).to have_content(group.to_s)
      end

      inactive_chapter.groups.each do |group|
        expect(page).to_not have_content(group.to_s)
      end
    end
  end
end
