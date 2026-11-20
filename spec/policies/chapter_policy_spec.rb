require 'rails_helper'

RSpec.describe ChapterPolicy do
  subject(:policy) { described_class.new(user, chapter) }

  let(:chapter) { Fabricate(:chapter) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  describe '#index?' do
    context 'when user is admin' do
      let(:user) { admin }

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

  describe '#edit?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.edit?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.edit?).to be false
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

  describe '#members?' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'permits access' do
        expect(policy.members?).to be true
      end
    end

    context 'when user is regular member' do
      let(:user) { regular_member }

      it 'denies access' do
        expect(policy.members?).to be false
      end
    end

    describe '#contact?' do
      context 'when user is a banned organiser of this chapter' do
        let(:user) do
          Fabricate(:member).tap do |member|
            member.add_role(:organiser, chapter)
            Fabricate(:ban, member:)
          end
        end

        it 'denies access' do
          expect(policy.contact?).to be(false)
        end
      end

      context 'when user is a banned admin' do
        let(:user) { admin.tap { |member| Fabricate(:ban, member:) } }

        it 'denies access' do
          expect(policy.contact?).to be(false)
        end
      end

      context 'when an organiser ban has expired' do
        let(:user) do
          Fabricate(:member).tap do |member|
            member.add_role(:organiser, chapter)
            Fabricate(:ban, member:).update_column(:expires_at, 1.day.ago)
          end
        end

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end

      context 'when user organises this chapter' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser, chapter) } }

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end

      context 'when user organises another chapter' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser, Fabricate(:chapter)) } }

        it 'denies access' do
          expect(policy.contact?).to be(false)
        end
      end

      context 'when user is admin' do
        let(:user) { admin }

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end

      context 'when user is a regular member' do
        let(:user) { regular_member }

        it 'denies access' do
          expect(policy.contact?).to be(false)
        end
      end

      context 'when user is a global organiser' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser) } }

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end

      context 'when user only organises a workshop in this chapter' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser, Fabricate(:workshop, chapter:)) } }

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end

      context 'when user only organises an event in this chapter' do
        let(:user) do
          Fabricate(:member).tap { |member| member.add_role(:organiser, Fabricate(:event, chapters: [chapter])) }
        end

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end

      context 'when user only organises a meeting in this chapter' do
        let(:user) do
          Fabricate(:member).tap { |member| member.add_role(:organiser, Fabricate(:meeting, chapters: [chapter])) }
        end

        it 'permits access' do
          expect(policy.contact?).to be(true)
        end
      end
    end

    describe '#contact_index?' do
      context 'when user is a banned chapter organiser' do
        let(:user) do
          Fabricate(:member).tap do |member|
            member.add_role(:organiser, chapter)
            Fabricate(:ban, member:)
          end
        end

        it 'denies access' do
          expect(policy.contact_index?).to be(false)
        end
      end

      context 'when user is a banned admin' do
        let(:user) { admin.tap { |member| Fabricate(:ban, member:) } }

        it 'denies access' do
          expect(policy.contact_index?).to be(false)
        end
      end

      context 'when an organiser ban has expired' do
        let(:user) do
          Fabricate(:member).tap do |member|
            member.add_role(:organiser, chapter)
            Fabricate(:ban, member:).update_column(:expires_at, 1.day.ago)
          end
        end

        it 'permits access' do
          expect(policy.contact_index?).to be(true)
        end
      end

      context 'when user is a chapter organiser' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser, Fabricate(:chapter)) } }

        it 'permits access' do
          expect(policy.contact_index?).to be(true)
        end
      end

      context 'when user is a global organiser' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser) } }

        it 'permits access' do
          expect(policy.contact_index?).to be(true)
        end
      end

      context 'when user is an admin' do
        let(:user) { admin }

        it 'permits access' do
          expect(policy.contact_index?).to be(true)
        end
      end

      context 'when user only organises a workshop' do
        let(:user) { Fabricate(:member).tap { |member| member.add_role(:organiser, Fabricate(:workshop, chapter:)) } }

        it 'permits access' do
          expect(policy.contact_index?).to be(true)
        end
      end

      context 'when user is a regular member' do
        let(:user) { regular_member }

        it 'denies access' do
          expect(policy.contact_index?).to be(false)
        end
      end
    end
  end
end
