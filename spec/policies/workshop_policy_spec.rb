RSpec.describe WorkshopPolicy do
  subject(:policy) { described_class.new(user, workshop) }

  let(:workshop) { Fabricate(:workshop) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#new?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.new?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.new?).to be false
      end
    end
  end

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

  describe '#invite?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.invite?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.invite?).to be false
      end
    end
  end

  describe '#update?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.update?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.update?).to be false
      end
    end
  end

  describe '#destroy?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.destroy?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.destroy?).to be false
      end
    end
  end
end
