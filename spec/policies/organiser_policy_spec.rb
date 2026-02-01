RSpec.describe OrganiserPolicy do
  subject { described_class.new(user, organiser) }

  let(:organiser) { Fabricate(:member) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#index?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end
  end

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

  describe '#destroy?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.destroy?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end
  end
end
