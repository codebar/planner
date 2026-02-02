RSpec.describe AdminPortalPolicy do
  subject { described_class.new(user, :admin_portal) }

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
end
