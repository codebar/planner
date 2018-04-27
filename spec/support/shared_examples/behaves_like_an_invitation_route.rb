shared_examples 'invitation route' do
  context 'accept an invitation' do
    scenario 'when there are available spots' do
      Tutorial.create(title: 'title')
      visit invitation_route
      click_on 'Attend'

      expect(page).to have_link 'I can no longer attend'
      expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
    end

    scenario 'when there are no available spots' do
      set_no_available_slots
      visit invitation_route

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

    scenario 'when already confirmed' do
      invitation.update_attribute(:attending, false)
      visit invitation_route

      expect(page).to have_selector(:link_or_button, 'Attend')
      expect(page).to_not have_content 'I can no longer attend'
    end

    scenario 'when already RSVPd to another event on same evening' do
      invitation.update_attributes(attending: true, member_id: member.id)

      invitation2 = Fabricate(:coach_workshop_invitation)
      invitation2_route = invitation_path(invitation2)

      visit invitation2_route
      click_on 'Attend'

      expect(page).to have_content("You have already RSVP'd to another workshop on this date. If you would prefer to attend this workshop, please cancel your other RSVP first.")
      expect(page).to have_selector(:link_or_button, 'Attend')
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
