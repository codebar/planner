RSpec.feature 'managing workshop attendances', type: :feature do
  context 'when an admin' do
    let(:member) { Fabricate(:member) }
    let(:chapter) { Fabricate(:chapter) }
    let(:workshop) { Fabricate(:workshop, chapter:) }
    let!(:invitation) { Fabricate(:workshop_invitation, workshop:, attending: true) }

    before do
      login_as_admin(member)
      invitation
    end

    describe '#verify_attendance' do
      let(:workshop) { Fabricate(:workshop, chapter:, date_and_time: Time.zone.now - 1.day) }

      scenario 'can verify that a member has attended the workshop' do
        visit admin_workshop_path(workshop)
        find('.verify_attendance').click

        expect(page).to have_css('.fa-check-square')
      end

      scenario 'verifies and unverifies attendance with targeted row replacement', :js do
        second_invitation = Fabricate(:workshop_invitation, workshop:, attending: true)

        visit admin_workshop_path(workshop)

        # Capture the ID of the second row before clicking
        second_row_id = "attendee-row-#{second_invitation.id}"
        expect(page).to have_css("##{second_row_id}")

        # Verify first attendee
        first('.verify_attendance').click
        expect(page).to have_css('.fa-check-square', count: 1, wait: 5)

        # Unverify the same attendee
        first('.verify_attendance').click
        expect(page).to have_css('.fa-check-square', count: 0, wait: 5)

        # The unclicked row should still exist with its original ID, proving targeted replacement
        expect(page).to have_css("##{second_row_id}")
      end
    end

    scenario 'can remove a member from the attendee list' do
      visit admin_workshop_path(workshop)
      expect(page).to have_css('.cancel_attendance', wait: 5)
      find('.cancel_attendance').click

      expect(page).to have_text('0 are attending as students')
    end

    scenario 'can move a member from the waiting list to the attendee list' do
      other_invitation = Fabricate(:workshop_invitation, workshop:, attending: nil)
      WaitingList.add(other_invitation)

      visit admin_workshop_path(workshop)
      find('.waiting_list').click

      expect(page).to have_text('2 are attending as students')
      expect(page).to have_text(I18n.l(other_invitation.reload.rsvp_time))
      expect(page).to have_css('i.fa-hat-wizard')
    end

    scenario 'can rsvp an invited student to the workshop', :js do
      login_as_admin(member)

      other_invitation = Fabricate(:workshop_invitation, workshop:, attending: nil)
      student = other_invitation.member

      visit admin_workshop_path(workshop)
      expect(page).to have_text('1 are attending as students')
      expect(page).to have_no_css('i.fa-magic')

      click_link 'RSVP a member'
      fill_in 'q', with: "#{student.name} #{student.surname}"
      click_button 'Search'

      expect(page).to have_text('No response')
      click_button 'RSVP'
      expect(page).to have_text('Attending', wait: 5)

      visit admin_workshop_path(workshop)
      expect(page).to have_text('2 are attending as students', wait: 5)
      expect(page).to have_text(I18n.l(other_invitation.reload.rsvp_time))
      expect(page).to have_css('.fa-hat-wizard')
    end

    scenario 'can view the tutorial and note set by an attendee' do
      invitation = Fabricate(:attending_workshop_invitation, workshop:)
      login_as_admin(member)

      visit admin_workshop_path(workshop)
      expect(page).to have_text(invitation.note)
      expect(page).to have_text(invitation.tutorial)
    end

    describe '#changes' do
      before do
        # Workshop invitations without `attending` status
        Fabricate(:workshop_invitation, workshop:, role: 'Coach')
        Fabricate(:workshop_invitation, workshop:, role: 'Student')

        # Not attending
        Fabricate(:workshop_invitation, workshop:, role: 'Coach', attending: false)
        Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: false)

        # Attending, with a student having been manually added/confirmed by an organiser
        Fabricate(:attending_workshop_invitation, workshop:, role: 'Coach')
        Fabricate(:attending_workshop_invitation, workshop:, role: 'Student')
        overridden = Fabricate(:attending_workshop_invitation, workshop:, role: 'Student')
        overridden.update(last_overridden_by_id: member.id)
      end

      scenario 'can verify if a invitation has been overridden by an organiser' do
        visit admin_workshop_changes_path(workshop)

        expect(page).to have_css(
          '.coaches-table tbody tr',
          count: workshop.invitations.to_coaches.where.not(attending: nil).count
        )
        expect(page).to have_css(
          '.students-table tbody tr',
          count: workshop.invitations.to_students.where.not(attending: nil).count
        )

        expect(page).to have_link(member.name_and_surname, href: admin_member_path(member.id))
      end
    end
  end
end
