require 'spec_helper'

feature 'Managing organisers' do
  let(:member) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }

  scenario 'non admin cannot manage organisers' do
    login(member)

    visit admin_chapter_organisers_path(chapter)
    expect(current_url).to eq(root_url)
  end

  context 'an admin' do
    before do
      login_as_admin(member)
    end

    scenario 'can view a list of chapter organisers' do
      other_organiser = Fabricate(:member)
      other_organiser.add_role :organiser, chapter

      visit admin_chapter_organisers_path(chapter)

      chapter.organisers.each do |organiser|
        expect(page).to have_content(organiser.full_name)
      end
    end

    scenario 'can add a new organiser to a chapter' do
      chapter_subscriber = Fabricate(:member)
      chapter = Fabricate(:chapter_with_groups)
      subscription = Fabricate(:subscription, member: chapter_subscriber, group: chapter.groups.first)
      visit admin_chapter_organisers_path(chapter)

      select chapter_subscriber.full_name, from: 'organiser[organiser]'
      click_on 'Add organiser'

      within '.organisers' do
        expect(page).to have_content(chapter_subscriber.full_name)
      end
    end

    scenario 'can remove an organiser from a chapter' do
      puts chapter.organisers.first
      visit admin_chapter_organisers_path(chapter)

      click_on 'Remove'

      within '.organisers' do
        expect(page).to_not have_content(chapter.organisers.first.full_name)
      end
    end
  end

end
