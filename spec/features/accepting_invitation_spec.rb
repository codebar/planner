require 'spec_helper'

feature 'a member can accept an invitation' do
  let(:invitation) { Fabricate(:invitation) }

  scenario 'when they access they invitation acceptance path', wip: true do
    visit accept_invitation_path(invitation)

    current_url.should eq root_url
    expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
  end
end

