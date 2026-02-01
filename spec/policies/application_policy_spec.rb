RSpec.describe ApplicationPolicy do
  subject { described_class.new(user, record) }

  let(:record) { double('record') }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#index?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(subject.index?).to be false
    end
  end

  describe '#create?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(subject.create?).to be false
    end
  end

  describe '#new?' do
    let(:user) { admin }

    it 'delegates to create?' do
      expect(subject.new?).to eq(subject.create?)
    end
  end

  describe '#update?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(subject.update?).to be false
    end
  end

  describe '#edit?' do
    let(:user) { admin }

    it 'delegates to update?' do
      expect(subject.edit?).to eq(subject.update?)
    end
  end

  describe '#destroy?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(subject.destroy?).to be false
    end
  end
end
