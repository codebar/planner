RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { instance_double(ApplicationRecord) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#index?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(policy.index?).to be false
    end
  end

  describe '#create?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(policy.create?).to be false
    end
  end

  describe '#new?' do
    let(:user) { admin }

    it 'delegates to create?' do
      expect(policy.new?).to eq(policy.create?)
    end
  end

  describe '#update?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(policy.update?).to be false
    end
  end

  describe '#edit?' do
    let(:user) { admin }

    it 'delegates to update?' do
      expect(policy.edit?).to eq(policy.update?)
    end
  end

  describe '#destroy?' do
    let(:user) { admin }

    it 'denies access by default' do
      expect(policy.destroy?).to be false
    end
  end
end
