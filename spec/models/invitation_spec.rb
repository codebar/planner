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

  describe 'cache invalidation' do
    let(:member) { Fabricate(:member) }
    let(:event) { Fabricate(:event) }

    it 'clears member cache when attending changes' do
      invitation = Fabricate(:invitation, member: member, event: event, attending: false)
      expect(member).to receive(:clear_attending_event_ids_cache!)
      invitation.update!(attending: true)
    end
  end
end
