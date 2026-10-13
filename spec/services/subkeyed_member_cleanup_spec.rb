# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubkeyedMemberCleanup do
  subject(:cleanup) { described_class.call(dry_run:) }

  let(:dry_run) { false }
  let(:subkeyed_key) { 'aB3xK9mQ7vN2pR5sT8uW1yZ4cD6fG0hJ' }
  let(:second_key) { 'zY9wV8uT7sR6qP5oN4mL3kJ2iH1gF0eD' }

  def create_subkeyed_member(key: subkeyed_key, name_value: 'Viktoriya Kravchenko', surname: 'Kravchenko', created_at: nil)
    member = Member.new(email: key, name: name_value, surname:,
                        about_you: 'Created by the sub fallback', accepted_toc_at: Time.zone.now)
    member.save(validate: false)
    member.update_columns(created_at:) if created_at
    member.auth_services.create!(provider: 'codebar', uid: key)
    member
  end

  # rubocop:disable Metrics/AbcSize -- table of fixture lambdas; one per OWNED_DATA relation
  def owned_data_seeder
    {
      subscriptions: ->(member) { Fabricate(:subscription, member:) },
      workshop_invitations: ->(member) { Fabricate(:workshop_invitation, member:) },
      meeting_invitations: ->(member) { Fabricate(:meeting_invitation, member:) },
      invitations: ->(member) { Fabricate(:invitation, member:) },
      roles: ->(member) { member.add_role(:organiser, Fabricate(:chapter)) },
      bans: ->(member) { Fabricate(:ban, member:) },
      feedbacks: ->(member) { Fabricate(:feedback, coach: member) },
      member_notes: ->(member) { member.member_notes.create!(member:, author_id: member.id, note: 'x') }
    }
  end
  # rubocop:enable Metrics/AbcSize

  def seed_owned_data(relation, member)
    owned_data_seeder.fetch(relation).call(member)
  end

  describe 'detection' do
    let(:dry_run) { true }

    it 'flags a member whose email equals its codebar auth service uid' do
      member = create_subkeyed_member

      result = cleanup

      expect(result.detected).to eq(1)
      expect(result.deactivated).to eq(1)
      expect(result.skipped).to eq(0)
      expect(member.id).to be_present
    end

    it 'flags a sub-keyed member whose name is a real name, not the key value' do
      member = create_subkeyed_member(name_value: 'Andrew Steel')

      result = cleanup

      expect(result.detected).to eq(1)
      expect(member.email).to eq(subkeyed_key)
    end

    it 'never renames a member with a normal email' do
      member = Fabricate(:member)
      member.auth_services.create!(provider: 'codebar', uid: member.email)

      expect(cleanup.detected).to eq(0)
    end

    it 'ignores a sub-keyed member created before the cutoff' do
      create_subkeyed_member(created_at: described_class::CUTOFF_TIME - 1.day)

      expect(cleanup.detected).to eq(0)
    end

    it 'ignores a sub-keyed email with no codebar auth service' do
      member = Member.new(email: subkeyed_key, name: 'X', surname: 'Y',
                          about_you: 'x', accepted_toc_at: Time.zone.now)
      member.save(validate: false)

      expect(cleanup.detected).to eq(0)
    end

    it 'ignores members already handled: renamed by this cleanup or by the tooling it follows' do
      create_subkeyed_member.tap { |m| m.update_columns(email: 'subkeyed.9.deactivated@codebar.io') }
                            .auth_services.update_all(uid: 'subkeyed.9.deactivated@codebar.io')
      create_subkeyed_member.tap { |m| m.update_columns(email: 'duplicate.9.merged-into.8@codebar.io') }
                            .auth_services.update_all(uid: 'duplicate.9.merged-into.8@codebar.io')
      create_subkeyed_member.tap { |m| m.update_columns(email: "deleted_user_#{Time.zone.now.to_fs(:number)}@codebar.io") }
                            .auth_services.update_all(uid: 'removed-manually')

      expect(cleanup.detected).to eq(0)
    end
  end

  describe 'deactivation' do
    it 'removes auth services, renames the email, and adds an audit note with the original value' do
      member = create_subkeyed_member

      result = cleanup

      member.reload
      expect(result.deactivated).to eq(1)
      expect(member.email).to eq("subkeyed.#{member.id}.deactivated@codebar.io")
      expect(member.auth_services).to be_empty
      note = MemberNote.find_by(member_id: member.id)
      expect(note.note).to include("Original email/uid: #{subkeyed_key}")
      expect(note.note).to match(/Deactivated \d{4}-\d{2}-\d{2}T\d{2}:\d{2}/)
      expect(note.note).to include('Login will stay off until the fail-closed strategy guard ships')
      expect(note.author_id).to eq(member.id)
    end

    it 'is idempotent: a second run detects nothing and writes nothing' do
      create_subkeyed_member

      cleanup
      second = described_class.call(dry_run:)

      expect(second.detected).to eq(0)
      expect(second.deactivated).to eq(0)
      expect(MemberNote.count).to eq(1)
    end

    context 'with dry_run' do
      let(:dry_run) { true }

      it 'reports the deactivation without writing' do
        member = create_subkeyed_member

        result = cleanup

        member.reload
        expect(result.deactivated).to eq(1)
        expect(member.email).to eq(subkeyed_key)
        expect(member.auth_services.where(provider: 'codebar')).to exist
        expect(MemberNote.where(member_id: member.id)).not_to exist
      end
    end
  end

  describe 'skip rule (data ownership)' do
    it 'skips a sub-keyed member that owns a subscription, never touching it' do
      member = create_subkeyed_member
      Fabricate(:subscription, member:)

      result = cleanup

      member.reload
      expect(result.skipped).to eq(1)
      expect(result.deactivated).to eq(0)
      expect(member.email).to eq(subkeyed_key)
      expect(member.auth_services.where(provider: 'codebar')).to exist
    end

    it 'skips a sub-keyed member that owns roles, bans, feedbacks, or notes' do
      member = create_subkeyed_member
      member.add_role(:organiser, Fabricate(:chapter))

      result = cleanup

      expect(result.skipped).to eq(1)
      expect(member.reload.email).to eq(subkeyed_key)
    end

    it 'skips a sub-keyed member that owns workshop invitations' do
      member = create_subkeyed_member
      Fabricate(:workshop_invitation, member:)

      result = cleanup

      expect(result.skipped).to eq(1)
    end

    it 'skips for every relation in OWNED_DATA, so a wrong key fails the suite' do
      described_class::OWNED_DATA.each_with_index do |(relation, _label), i|
        key = "owned#{i}Key0123456789abcdefgh"
        member = create_subkeyed_member(key:)
        seed_owned_data(relation, member)

        result = cleanup

        expect(result.skipped).to eq(1), "OWNED_DATA relation #{relation} did not trigger the skip"
        expect(member.reload.email).to eq(key)
      end
    end

    it 'counts skips as handled so a later verify can pass' do
      member = create_subkeyed_member
      Fabricate(:subscription, member:)

      result = cleanup

      expect(result.skipped).to eq(1)
      expect(result.detected).to eq(1)
    end
  end

  describe 'mixing both outcomes' do
    it 'deactivates only the data-free member and skips the data owner' do
      create_subkeyed_member(name_value: 'Clean Case')
      owner = create_subkeyed_member(key: second_key, name_value: 'Data Owner')
      Fabricate(:subscription, member: owner)

      result = cleanup

      expect(result.detected).to eq(2)
      expect(result.deactivated).to eq(1)
      expect(result.skipped).to eq(1)
      expect(Member.where('email LIKE ?', 'subkeyed.%.deactivated@codebar.io').count).to eq(1)
      expect(owner.reload.email).to eq(second_key)
    end
  end

  describe 'exclusion chain (handled prefixes)' do
    let(:dry_run) { true }

    it 'excludes a renamed member and keeps a live one: inclusion/exclusion control pair' do
      excluded = create_subkeyed_member.tap do |member|
        member.update_columns(email: 'duplicate.31452.merged-into.17284@codebar.io')
      end
      excluded.auth_services.update_all(uid: 'duplicate.31452.merged-into.17284@codebar.io')
      kept = create_subkeyed_member(key: second_key)

      ids = described_class.new(dry_run: true).detectable_members.map(&:id)

      expect(ids).not_to include(excluded.id)
      expect(ids).to include(kept.id)
    end
  end
end
