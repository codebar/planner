# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionTombstoneBackfill, type: :service do
  subject(:backfill) { described_class.call(dry_run:) }

  let(:dry_run) { false }
  let(:group) { Fabricate(:group) }

  def record_unsubscribe(member, tracked_group, at:)
    PublicActivity::Activity.create!(owner: member, key: 'subscription.removed',
                                     trackable: tracked_group, created_at: at)
  end

  it 'creates a tombstone for a member whose subscription row is gone' do
    member = Fabricate(:member)
    record_unsubscribe(member, group, at: 3.days.ago)

    expect { backfill }.to change(Subscription, :count).by(1)

    tombstone = Subscription.discarded.sole
    expect(tombstone.member_id).to eq(member.id)
    expect(tombstone.group_id).to eq(group.id)
    expect(tombstone.created_at).to be_within(1.second).of(3.days.ago)
    expect(tombstone.discarded_at).to be_within(1.second).of(3.days.ago)
  end

  it 'reads the admin-path key where the affected member is the recipient' do
    admin = Fabricate(:member)
    affected = Fabricate(:member)
    PublicActivity::Activity.create!(owner: admin, key: 'subscription.admin_updated',
                                     trackable: group, recipient: affected, created_at: 2.days.ago)

    expect { backfill }.to change(Subscription, :count).by(1)
    expect(Subscription.discarded.sole.member_id).to eq(affected.id)
  end

  it 'collapses repeat unsubscribes to the latest event' do
    member = Fabricate(:member)
    record_unsubscribe(member, group, at: 10.days.ago)
    record_unsubscribe(member, group, at: 2.days.ago)

    backfill

    expect(Subscription.discarded.where(member:, group:).count).to eq(1)
    expect(Subscription.discarded.sole.created_at).to be_within(1.second).of(2.days.ago)
  end

  it 'skips pairs that already have a subscription row' do
    member = Fabricate(:member)
    Fabricate(:subscription, member:, group:)
    record_unsubscribe(member, group, at: 1.day.ago)

    expect { backfill }.not_to change(Subscription, :count)
  end

  it 'is idempotent: a second run creates nothing' do
    member = Fabricate(:member)
    record_unsubscribe(member, group, at: 1.day.ago)

    backfill
    expect { described_class.call(dry_run:) }.not_to change(Subscription, :count)
  end

  it 'skips events whose member no longer exists' do
    PublicActivity::Activity.create!(owner_id: 9_999_999, owner_type: 'Member',
                                     key: 'subscription.removed', trackable: group,
                                     created_at: 1.day.ago)

    result = described_class.call(dry_run:)

    expect(result.created).to eq(0)
    expect(result.skipped_missing_member).to eq(1)
  end

  context 'with dry_run' do
    let(:dry_run) { true }

    it 'counts without writing' do
      member = Fabricate(:member)
      record_unsubscribe(member, group, at: 1.day.ago)

      result = described_class.call(dry_run:)

      expect(result.created).to eq(1)
      expect(Subscription.count).to eq(0)
    end
  end
end
