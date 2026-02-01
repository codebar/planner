RSpec.describe ChapterPolicy do
  subject { described_class.new(user, chapter) }

  let(:chapter) { Fabricate(:chapter) }
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

  describe '#edit?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.edit?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.edit?).to be false
      end
    end
  end

  describe '#update?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.update?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end
  end

  describe '#members?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(subject.members?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(subject.members?).to be false
      end
    end
  end
end
