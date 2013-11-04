shared_examples "invitation route" do
  scenario 'when there are available spots' do
    visit invitation_path

    current_url.should eq root_url
    expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
  end

  scenario 'when they have already confirmed their attendance' do
    invitation.update_attribute(:attending, true)
    visit invitation_path

    current_url.should eq root_url
    expect(page).to have_content("You have alredy confirmed you attendance for this meeting!")
  end

  scenario 'when there are available spots' do
    set_no_available_slots
    visit invitation_path

    current_url.should eq root_url
    expect(page).to have_content("Unfortunately there are no more spaces left :(.")
  end
end
