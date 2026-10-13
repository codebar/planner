# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberNotePolicy do
  subject(:policy) { described_class.new(user, member_note) }

  let(:member) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }
  let(:author) { Fabricate(:member) }
  let(:member_note) { Fabricate(:member_note, member:, author:) }
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

  %i[update? destroy?].each do |permission|
    describe "##{permission}" do
      context 'when user is an admin' do
        let(:user) { admin }

        it 'permits access' do
          expect(policy.public_send(permission)).to be true
        end
      end

      context 'when user is the note author' do
        let(:user) { author }

        it 'permits access' do
          expect(policy.public_send(permission)).to be true
        end
      end

      context 'when user organises a chapter the noted member belongs to' do
        let(:user) { Fabricate(:member) }

        before do
          Fabricate(:students, chapter:, members: [member])
          user.add_role(:organiser, chapter)
        end

        it 'permits access' do
          expect(policy.public_send(permission)).to be true
        end
      end

      context 'when user organises a chapter the noted member does not belong to' do
        let(:user) { Fabricate(:chapter_organiser) }

        it 'denies access' do
          expect(policy.public_send(permission)).to be false
        end
      end

      context 'when user is a regular member' do
        let(:user) { regular_member }

        it 'denies access' do
          expect(policy.public_send(permission)).to be false
        end
      end

      context 'when user is anonymous' do
        it 'denies access' do
          expect(described_class.new(nil, member_note).public_send(permission)).to be false
        end
      end
    end
  end
end
