require 'spec_helper'

describe InvitationPresenter do
  let(:invitation) { Fabricate(:student_workshop_invitation) }
  let(:invitation_presenter) { InvitationPresenter.new(invitation) }

  it '#member' do
    expect(MemberPresenter).to receive(:new).with(invitation.member)

    invitation_presenter.member
  end
end
