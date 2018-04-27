require 'spec_helper'

feature 'managing workshop attendances' do
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

        expect(page).to have_css('.fa-check-square-o')
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
    end

    xscenario 'can rsvp an invited student the the workshop' do
      other_invitation = Fabricate(:workshop_invitation, workshop: workshop, attending: nil)

      visit admin_workshop_path(workshop)
      expect(page).to have_content('1 are attending as students')

      select "#{other_invitation.member.full_name} (#{other_invitation.role})", from: 'workshop_invitations'

      expect(page).to have_content('2 are attending as students')
    end
  end
end
