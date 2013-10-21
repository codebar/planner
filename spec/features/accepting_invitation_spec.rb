require 'spec_helper'

feature 'a member can accept an invitation' do
  let(:invitation) { Fabricate(:invitation) }

  scenario 'when there are available spots' do
    visit accept_invitation_path(invitation)

    current_url.should eq root_url
    expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
  end

  scenario 'when they have already confirmed their attendance' do
    invitation.update_attribute(:attending, true)
    visit accept_invitation_path(invitation)

    current_url.should eq root_url
    expect(page).to have_content("You have alredy confirmed you attendance for this meeting!")
  end

  scenario 'when there are available spots' do
    invitation.sessions.update_attribute(:seats, 0)
    visit accept_invitation_path(invitation)

    current_url.should eq root_url
    expect(page).to have_content("Unfortunately there are no more spaces left :(.")
  end
end

