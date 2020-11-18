require 'spec_helper'

RSpec.feature 'Managing users', type: :feature do
  let(:member) { Fabricate(:member) }
  let(:student) { Fabricate(:student) }
  let(:admin) { Fabricate(:chapter_organiser) }
  let!(:invitation) { Fabricate(:attended_workshop_invitation, member: member) }
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
    click_on 'Suspend'

    select 'Violated attendance policy', from: 'ban_reason'
    fill_in 'ban_note', with: Faker::Lorem.word
    fill_in 'ban_expires_at', with: Time.zone.today + 1.month
    click_on 'Suspend member'

    expect(page).to have_content 'The user has been suspended'
  end

  scenario 'unsubscribe a user from group', js: true do
    visit admin_member_path student
    within '#subscriptions > li:first-child' do
      expect do
        accept_confirm { find('.fa-times').click }
      end.to change { student.subscriptions.count }.by(0)
    end

    expect(page).to have_content "You have unsubscribed #{student.full_name}"
  end

  scenario 'Send eligibility email to user' do
    visit admin_member_path student
    click_on 'Eligibility'

    expect(page).to have_content 'You have sent an eligibility confirmation request.'
  end

  scenario 'Warn a user' do
    visit admin_member_path member
    expect(page).to have_selector("a[data-confirm='Clicking OK will send an automated email to this user now to warn them about missing too many workshops. This cannot be undone. Are you sure?']")
    click_on 'Attendance'
    expect(page).to have_selector("a[data-confirm='#{member.name} has already received a warning about missing too many workshops on #{member.attendance_warnings.last.created_at.strftime("%Y-%m-%d at %H:%M")}. Are you sure you want to proceed with sending another one?']")
    expect(page).to have_content 'You have sent an attendance warning.'
  end

end
