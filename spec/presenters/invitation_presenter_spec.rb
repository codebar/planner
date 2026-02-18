RSpec.describe InvitationPresenter do
  let(:invitation) { Fabricate(:student_workshop_invitation) }
  let(:invitation_presenter) { InvitationPresenter.new(invitation) }

  it '#member' do
    expect(invitation_presenter.member).to eq(invitation.member)
  end

  describe '#attendance_status' do
    it 'returns Attending when attending' do
      invitation.accept!

      expect(invitation_presenter.attendance_status).to eq('Attending')
    end

    it 'returns RSVP when not attending' do
      expect(invitation_presenter.attendance_status).to eq('RSVP')
    end
  end
end
