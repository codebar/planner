require 'spec_helper'

RSpec.feature 'admin portal', type: :feature do
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

    scenario 'can view all active chapters and upcoming workshops listed' do
      chapter = Fabricate(:chapter_with_groups)
      workshop = Fabricate.times(2, :workshop)
      inactive_chapter = Fabricate(:chapter_with_groups, active: false)
      visit admin_root_path

      chapter.groups.each do |group|
        expect(page).to have_content(group.to_s)
      end

      workshops.each do |workshop|
        expect(page).to have_content(workshop.chapter.name)
        expect(page).to have_content(I18n.l(workshop.date_and_time, format: :humanize_date_with_time))
      end

      inactive_chapter.groups.each do |group|
        expect(page).to_not have_content(group.to_s)
      end
    end
  end
end
