require 'spec_helper'

feature 'Managing users' do
  let(:member) { Fabricate(:member) }
  let(:admin) { Fabricate(:chapter_organiser) }
  let!(:invitation) { Fabricate(:attended_workshop_invitation, attending: true, member: member) }
  let!(:attending_invitation) { Fabricate(:attending_workshop_invitation, member: member) }

  before do
    login admin
  end

  scenario 'View a user' do
    visit admin_member_path member

    expect(page).to have_content('RSVPed to 2 workshops and attended 1.')
    expect(page).to have_content member.name
    expect(page).to have_content member.email
    expect(page).to have_content member.about_you
    expect(page).to have_content invitation.note
    expect(page).to have_content attending_invitation.note
  end

  scenario 'Add a note to a user' do
    visit admin_member_path member
    fill_in 'member_note_note', with: 'Bananas and custard'
    click_on 'Add note'

    expect(page).to have_content 'Bananas and custard'
  end

  scenario 'Ban a user' do
    visit admin_member_path member
    click_on 'Ban'

    select 'Violated attendance policy', from: 'ban_reason'
    fill_in 'ban_note', with: Faker::Lorem.word
    fill_in 'ban_expires_at', with: Time.zone.today + 1.month
    click_on 'Ban user'

    expect(page).to have_content 'The user has been banned'
  end
end
