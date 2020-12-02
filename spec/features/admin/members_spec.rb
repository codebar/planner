require 'spec_helper'

RSpec.describe 'Admin managing members', type: :feature do
  let(:member) { Fabricate(:student) }
  let(:admin) { Fabricate(:chapter_organiser) }
  let(:invitation) { Fabricate(:attended_workshop_invitation, member: member) }

  before do
    invitation

    login(admin)
    visit admin_member_path(member)
  end

  describe 'Admin managing members' do
    it 'can view member information' do
      expect(page).to have_content(member.name)
      expect(page).to have_content(member.email)
      expect(page).to have_content(member.about_you)
    end

    it 'can view a summary of member event attendances' do
      within '.attendance-summary' do
        expect(page).to have_content('1 workshops')
      end
    end

    it 'can add a note about a member' do
      click_on 'Add note'
      fill_in 'member_note_note', with: 'Bananas and custard'
      click_on 'Save'

      within '.note' do
        expect(page).to have_content 'Bananas and custard'
        expect(page).to have_content "Note added by #{admin.full_name}"
      end
    end

    it 'can suspend a member' do
      click_on 'Suspend'

      select 'Violated attendance policy', from: 'ban_reason'
      fill_in 'ban_note', with: Faker::Lorem.word
      fill_in 'ban_expires_at', with: Time.zone.today + 1.month
      click_on 'Suspend member'

      expect(page).to have_content 'Member marked as supended and suspension email sent.'
      within '.suspension' do
        expect(page).to have_content "Suspended until #{I18n.l(Time.zone.today + 1.month)} by #{admin.full_name}"
      end
    end

    it 'can unsubscribe a member from group', js: true do
      within '#subscriptions > li:first-child' do
        expect do
          accept_confirm { find('.fa-times').click }
        end.to change { member.subscriptions.count }.by(0)
      end

      expect(page).to have_content "Successfully unsubscribed #{member.full_name}"
    end

    it 'can send an eligibility email to a member' do
      click_on 'Send eligibility inquiry'

      expect(page).to have_content 'Eligibility inquiry email sent.'
      within '.eligibility-inquiry' do
        expect(page).to have_content "Sent eligibility inquiry email by #{admin.full_name}"
      end
    end

    it 'can send an attendance warning to a member' do
      expect(page).to have_selector("a[data-confirm='Clicking OK will send an automated email to this user now to warn them about missing too many workshops. This cannot be undone. Are you sure?']")
      click_on 'Send attendance warning'
      expect(page).to have_selector("a[data-confirm='#{member.name} has already received a warning about missing too many workshops on #{member.attendance_warnings.last.created_at.strftime('%Y-%m-%d at %H:%M')}. Are you sure you want to proceed with sending another one?']")

      expect(page).to have_content 'Attendance warning email sent.'
      within '.attendance-warning' do
        expect(page).to have_content "Sent attendance warning email by #{admin.full_name}"
      end
    end
  end
end
