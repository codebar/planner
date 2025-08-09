require 'spec_helper'

RSpec.feature 'managing workshop attendances', type: :feature do
  MAX_RETRIES = 3

  context 'an admin' do
    let(:member) { Fabricate(:member) }
    let(:chapter) { Fabricate(:chapter) }
    let(:workshop) { Fabricate(:workshop, chapter: chapter) }
    let!(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, attending: true) }

    before do
      login_as_admin(member)
    end

    context ' #verify_attendance' do
      let(:workshop) { Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.now - 1.day) }

      scenario 'can verify that a member has attended the workshop' do
        visit admin_workshop_path(workshop)
        find('.verify_attendance').click

        expect(page).to have_css('.fa-check-square')
      end
    end

    scenario 'can remove a member from the attendee list' do
      visit admin_workshop_path(workshop)
      find('.cancel_attendance').click

      expect(page).to have_content('0 are attending as students')
    end

    scenario 'can move a member from the waiting list to the attendee list' do
      other_invitation = Fabricate(:workshop_invitation, workshop: workshop, attending: nil)
      WaitingList.add(other_invitation)

      visit admin_workshop_path(workshop)
      find('.waiting_list').click

      expect(page).to have_content('2 are attending as students')
      expect(page).to have_content(I18n.l(other_invitation.reload.rsvp_time))
      expect(page).to have_selector('i.fa-hat-wizard')
    end

    scenario 'can rsvp an invited student to the workshop', js: true do
      login_as_admin(member)

      other_invitation = Fabricate(:workshop_invitation, workshop: workshop, attending: nil)

      visit admin_workshop_path(workshop)
      expect(page).to have_content('1 are attending as students')
      expect(page).to_not have_selector('i.fa-magic')

      find('span', text: 'Select a member to RSVP', visible: true).click
      find('li', text: "#{other_invitation.member.full_name} (#{other_invitation.role})", visible: true).click

      expect(page).to have_content('2 are attending as students')

      expect(page).to have_content(I18n.l(other_invitation.reload.rsvp_time))
      expect(page).to have_css('.fa-hat-wizard')
    end

    scenario 'can view the tutorial and note set by an attendee' do
      invitation = Fabricate(:attending_workshop_invitation, workshop: workshop)
      login_as_admin(member)

      visit admin_workshop_path(workshop)
      expect(page).to have_content(invitation.note)
      expect(page).to have_content(invitation.tutorial)
    end

    context '#changes' do
      before do
        # Workshop invitations without `attending` status
        Fabricate(:workshop_invitation, workshop: workshop, role: 'Coach')
        Fabricate(:workshop_invitation, workshop: workshop, role: 'Student')

        # Not attending
        Fabricate(:workshop_invitation, workshop: workshop, role: 'Coach', attending: false)
        Fabricate(:workshop_invitation, workshop: workshop, role: 'Student', attending: false)

        # Attending, with a student having been manually added/confirmed by an organiser
        Fabricate(:attending_workshop_invitation, workshop: workshop, role: 'Coach')
        Fabricate(:attending_workshop_invitation, workshop: workshop, role: 'Student')
        overridden = Fabricate(:attending_workshop_invitation, workshop: workshop, role: 'Student')
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
