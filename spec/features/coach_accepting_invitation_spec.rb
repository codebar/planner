require 'spec_helper'

feature 'a Coach can' do

  context "#session" do
    let(:invitation) { Fabricate(:coach_session_invitation) }
    let(:invitation_route) { invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.sessions.host.update_attribute(:seats, 0) }

    it_behaves_like "invitation route"

  end
end
