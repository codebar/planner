RSpec.describe GroupPolicy do
  subject(:policy) { described_class.new(user, group) }

  let(:group) { Fabricate(:group) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#create?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.create?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.create?).to be false
      end
    end
  end

  describe '#show?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.show?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.show?).to be false
      end
    end
  end
end
