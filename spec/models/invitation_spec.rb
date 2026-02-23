RSpec.describe Invitation do
  it_behaves_like InvitationConcerns, :invitation, :event

  context 'defaults' do
    it { is_expected.to have_attributes(attending: nil) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_uniqueness_of(:member_id).scoped_to(:event_id, :role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(%w[Student Coach]) }
  end

  describe '#student_spaces?' do
    it 'checks if there are any available spaces for students at the event' do
      student_invitation = Fabricate(:invitation)

      expect(student_invitation.student_spaces?).to eq(true)
    end
  end

  describe '#coach_spaces?' do
    it 'checks if there are any available spaces for coaches at the event' do
      coach_invitation = Fabricate(:coach_invitation)

      expect(coach_invitation.coach_spaces?).to eq(true)
    end
  end

  describe '#accept!' do
    let(:invitation) { Fabricate(:invitation, attending: false) }

    it 'sets attending to true' do
      invitation.accept!
      expect(invitation.reload.attending).to be true
    end

    it 'does not verify by default' do
      invitation.accept!
      expect(invitation.reload.verified).to be false
    end

    it 'allows immediate verification' do
      invitation.accept!(verified: true)
      expect(invitation.reload.verified).to be true
    end

    it 'raises RecordInvalid on validation failure' do
      allow(invitation).to receive(:valid?).and_return(false)
      expect { invitation.accept! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#verify!' do
    let(:invitation) { Fabricate(:invitation, verified: false) }

    it 'sets verified to true' do
      invitation.verify!
      expect(invitation.reload.verified).to be true
    end

    it 'raises RecordInvalid on validation failure' do
      allow(invitation).to receive(:valid?).and_return(false)
      expect { invitation.verify! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#decline!' do
    let(:invitation) { Fabricate(:invitation, attending: true) }

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
