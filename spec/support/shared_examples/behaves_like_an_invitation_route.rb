shared_examples "invitation route" do
  context "accept an invitation" do
    scenario 'when there are available spots' do
      visit invitation_route
      click_on "Attend"

      expect(page).to have_link "I can no longer attend"
      expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
    end

    scenario 'when there are no available spots' do
      set_no_available_slots
      visit invitation_route
      click_on "Attend"

      current_url.should eq invitation_url(invitation)
      expect(page).to have_content("Unfortunately there are no more spaces left :(.")
    end
  end

  context "unable to attend" do
    scenario 'when they are succesful' do
      invitation.update_attribute(:attending, true)
      visit invitation_route

      click_on "I can no longer attend"
      expect(page).to have_content(I18n.t("messages.rejected_invitation", name: invitation.member.name))
    end

    scenario 'when already confirmed' do
      invitation.update_attribute(:attending, false)
      visit invitation_route

      expect(page).to have_content "Attend"
      expect(page).to_not have_content "I can no longer attend"
    end
  end
end
