RSpec.describe MemberNotePolicy do
  subject { described_class.new(user, member_note) }

  let(:member_note) { Fabricate(:member_note) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#create?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.create?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end
  end
end
