require 'rails_helper'

RSpec.feature 'Chapter contact access by role' do
  let(:chapter) { Fabricate(:chapter) }

  def member_with(&)
    Fabricate(:member).tap(&)
  end

  def ban(member) = Fabricate(:ban, member:)

  {
    'an admin' => ->(member, _chapter) { member.add_role(:admin) },
    'a chapter organiser' => ->(member, chapter) { member.add_role(:organiser, chapter) },
    'a global organiser' => ->(member, _chapter) { member.add_role(:organiser) }
  }.each do |role, setup|
    scenario "#{role} sees the menu link and can open the contact form" do
      member = member_with { |m| setup.call(m, chapter) }
      login(member)

      visit root_path
      click_on 'Menu'
      expect(page).to have_link('Contact chapter')

      visit new_admin_chapter_contact_path(chapter)
      expect(page).to have_current_path(new_admin_chapter_contact_path(chapter))
    end
  end

  {
    'a student' => ->(member, chapter) { Fabricate(:subscription, member:, group: Fabricate(:students, chapter:)) },
    'a coach' => ->(member, chapter) { Fabricate(:subscription, member:, group: Fabricate(:coaches, chapter:)) },
    'a banned chapter organiser' => lambda { |member, chapter|
      member.add_role(:organiser, chapter)
      Fabricate(:ban, member:)
    },
    'a banned admin' => lambda { |member, _chapter|
      member.add_role(:admin)
      Fabricate(:ban, member:)
    }
  }.each do |role, setup|
    scenario "#{role} sees no menu link and is redirected from the contact form" do
      member = member_with { |m| setup.call(m, chapter) }
      login(member)

      visit root_path
      click_on 'Menu'
      expect(page).to have_no_link('Contact chapter')

      visit new_admin_chapter_contact_path(chapter)
      expect(current_url).to eq(root_url)
    end
  end
end
