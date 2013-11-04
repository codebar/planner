require 'spec_helper'

describe SessionInvitation do
  let(:invitation) { Fabricate(:session_invitation) }
  let!(:accepted_invitation) { 2.times {  Fabricate(:session_invitation, attending: true) } }

  it_behaves_like InvitationConcerns

end
