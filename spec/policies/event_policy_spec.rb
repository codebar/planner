RSpec.describe EventPolicy do
  subject { described_class.new(user, event) }

  let(:event) { Fabricate(:event) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#invite?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.invite?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.invite?).to be false
      end
    end
  end

  describe '#show?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.show?).to be false
      end
    end
  end
end
