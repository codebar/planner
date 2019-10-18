require 'spec_helper'

RSpec.feature 'a Coach can', type: :feature do
  context '#workshop' do
    let(:member) { Fabricate(:member) }
    let(:invitation) { Fabricate(:coach_workshop_invitation, member: member) }
    let(:invitation_route) { invitation_path(invitation) }
    let(:reject_invitation_route) { reject_invitation_path(invitation) }
    let(:accept_invitation_route) { accept_invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.workshop.host.update_attribute(:seats, 0) }

    before(:each) do
      login(member)
    end

    it_behaves_like 'invitation route'
  end
end
