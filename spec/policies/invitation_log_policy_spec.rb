require 'rails_helper'

RSpec.describe InvitationLogPolicy do
  subject(:policy) { described_class.new(user, invitation_log) }

  let(:workshop) { Fabricate(:workshop) }
  let(:invitation_log) { Fabricate(:invitation_log, loggable: workshop) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:chapter_organiser) do
    member = Fabricate(:member)
    member.add_role(:organiser, workshop.chapter)
    member
  end
  let(:regular_member) { Fabricate(:member) }

  describe '#index?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.index?).to be true
      end
    end

    context 'when user is chapter organiser' do
      let(:user) { chapter_organiser }

      it 'permits access' do
        expect(policy.index?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.index?).to be false
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

    context 'when user is chapter organiser' do
      let(:user) { chapter_organiser }

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
