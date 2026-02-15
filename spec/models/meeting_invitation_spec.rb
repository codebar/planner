RSpec.describe MeetingInvitation do
  it_behaves_like InvitationConcerns, :meeting_invitation, :meeting

  context 'defaults' do
    it { is_expected.to have_attributes(attending: nil) }
    it { is_expected.to have_attributes(attended: false) }
  end

  context 'validates' do
    it { is_expected.to validate_presence_of(:meeting) }
    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_uniqueness_of(:member_id).scoped_to(:meeting_id) }
  end

  describe '#accept!' do
    let(:invitation) { Fabricate(:meeting_invitation, attending: false) }

    it 'sets attending to true' do
      invitation.accept!
      expect(invitation.reload.attending).to be true
    end

    it 'raises RecordInvalid on validation failure' do
      allow(invitation).to receive(:valid?).and_return(false)
      expect { invitation.accept! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#decline!' do
    let(:invitation) { Fabricate(:meeting_invitation, attending: true) }

    it 'sets attending to false' do
      invitation.decline!
      expect(invitation.reload.attending).to be false
    end

    it 'raises RecordInvalid on validation failure' do
      allow(invitation).to receive(:valid?).and_return(false)
      expect { invitation.decline! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
