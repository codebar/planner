RSpec.shared_examples 'invitation route' do
  context 'viewing an invitation' do
    scenario 'renders a descriptive page title' do
      visit invitation_route

      expect(page).to have_title("Workshop invitation - #{humanize_date(invitation.workshop.date_and_time)} | codebar.io")
    end
  end

  context 'accept an invitation' do
    scenario 'when there are available spots' do
      tutorial = Fabricate(:tutorial)
      visit invitation_route

      select tutorial.title, from: :workshop_invitation_tutorial if invitation.for_student?

      click_on 'Attend'

      expect(page).to have_link 'I can no longer attend'
      expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
      expect(page.current_path).to eq(invitation_route)

      # admin view
      login_as_admin(member)
      visit admin_workshop_path(invitation.workshop)
      within 'tr.row.attendee' do
        expect(page).to have_content(member.full_name)
        expect(page).to have_selector('i.fa-history')
        expect(page).to_not have_selector('i.fa-magic')
      end
    end

    scenario 'they can RSVP directly through the invitation' do
      Tutorial.create(title: 'title')
      visit accept_invitation_route

      expect(page).to have_link 'I can no longer attend'
      expect(page.current_path).to eq(invitation_route)
      expect(page).to have_content(I18n.t('messages.accepted_invitation', name: member.name))
    end

    scenario 'when they have already RSVPed and are attempting to re-accept through the invitation link' do
      invitation.update_attribute(:attending, true)
      visit accept_invitation_route

      expect(current_url).to eq(invitation_url(invitation))
      expect(page).to have_content(I18n.t('messages.already_rsvped'))
    end

    scenario 'when there are no available spots' do
      set_no_available_slots
      visit invitation_route

      expect(current_url).to eq(invitation_url(invitation))
      expect(page).to have_content('The workshop is full')
    end

    scenario 'when there are no available spots and they accept through the invitation link' do
      set_no_available_slots
      visit accept_invitation_route

      expect(current_url).to eq(invitation_url(invitation))
      expect(page).to have_content('The workshop is full')
    end
  end

  context 'unable to attend' do
    scenario 'when they are successful' do
      invitation.update_attribute(:attending, true)
      visit invitation_route

      click_on 'I can no longer attend'
      expect(page).to have_content(I18n.t('messages.rejected_invitation', name: invitation.member.name))
    end

    scenario 'when they are successful and there is someone else on the waiting list' do
      waitinglisted = Fabricate(:workshop_invitation, workshop: invitation.workshop, role: invitation.role)
      WaitingList.add(waitinglisted)
      invitation.update_attribute(:attending, true)
      visit invitation_route
      expect(WaitingList.next_spot(invitation.workshop, invitation.role).present?).to eq(true)

      click_on 'I can no longer attend'

      expect(page).to have_content(I18n.t('messages.rejected_invitation', name: invitation.member.name))
      expect(waitinglisted.reload.automated_rsvp).to eq(true)
      expect(waitinglisted.reload.rsvp_time).to_not be_nil
      expect(WaitingList.next_spot(invitation.workshop, invitation.role).present?).to eq(false)
    end

    scenario 'when they are successful by accessing the link directly' do
      invitation.update_attribute(:attending, true)
      visit reject_invitation_route

      expect(page).to have_content(I18n.t('messages.rejected_invitation', name: invitation.member.name))
      expect(page.current_path).to eq(invitation_route)
    end

    scenario 'when already confirmed they are not attending' do
      invitation.update_attribute(:attending, false)
      visit invitation_route

      expect(page).to have_selector(:link_or_button, 'Attend')
      expect(page).to_not have_content 'I can no longer attend'
    end

    scenario 'when already confirmed they are not attending and reject by accessing the link directly' do
      invitation.update_attribute(:attending, false)
      visit reject_invitation_route

      expect(page).to have_content(I18n.t('messages.not_attending_already'))
      expect(page.current_path).to eq(invitation_route)
    end

    scenario 'when already RSVPd to another event on same evening' do
      invitation.update(attending: true, member_id: member.id)

      invitation2 = Fabricate(:coach_workshop_invitation)
      invitation2_route = invitation_path(invitation2)

      visit invitation2_route
      click_on 'Attend'

      expect(page).to have_content(I18n.t('messages.invitations.rsvped_to_other_workshop'))
      expect(page).to have_selector(:link_or_button, 'Attend')
    end

    scenario 'when already RSVPd to another event on same evening and attempting to RSVP directly through the link' do
      invitation.update(attending: true, member_id: member.id)

      invitation2 = Fabricate(:coach_workshop_invitation)
      invitation2_route = invitation_path(invitation2)

      visit accept_invitation_path(invitation2)

      expect(page).to have_content(I18n.t('messages.invitations.rsvped_to_other_workshop'))
    end

    scenario 'when the event is less than 3.5 hours from now' do
      invitation.workshop.update_attribute(:date_and_time, Time.zone.now + 3.hours)
      visit reject_invitation_route

      expect(page).to have_content('You can only change your RSVP status up to 3.5 hours before the workshop')
      expect(page.current_path).to eq(invitation_route)
    end

    scenario 'when the event is less than 3.5 hours from now and tje reject by accessing the link directly' do
      invitation.workshop.update_attribute(:date_and_time, Time.zone.now + 3.hours)
      visit reject_invitation_route

      expect(page).to have_content('You can only change your RSVP status up to 3.5 hours before the workshop')
      expect(page.current_path).to eq(invitation_route)
    end
  end

  context 'waiting list' do
    scenario 'is available when there are no spots left' do
      set_no_available_slots
      visit invitation_route

      click_on 'Join the waiting list'
      expect(page).to have_content('You have been added to the waiting list')

      click_on 'Remove from the waiting list'
      expect(page).to have_content('You have been removed from the waiting list')
    end
  end
end
