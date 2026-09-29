# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  describe 'validations' do
    it 'blocks a second active subscription for the same member and group' do
      subscription = Fabricate(:subscription)
      duplicate = Fabricate.build(:subscription, member: subscription.member, group: subscription.group)

      expect(duplicate).not_to be_valid
    end

    it 'allows subscribing again after the earlier period was discarded' do
      subscription = Fabricate(:subscription)
      subscription.discard!
      resubscription = Fabricate(:subscription, member: subscription.member, group: subscription.group)

      expect(resubscription).to be_valid
    end

    it 'ignores tombstones of other periods when validating uniqueness' do
      member = Fabricate(:member)
      group = Fabricate(:group)
      Fabricate(:discarded_subscription, member:, group:)
      Fabricate(:discarded_subscription, member:, group:, discarded_at: 1.week.ago)

      subscription = Fabricate.build(:subscription, member:, group:)
      expect(subscription).to be_valid
    end
  end

  describe '#discard' do
    it 'keeps the row with a discarded_at timestamp' do
      subscription = Fabricate(:subscription)

      subscription.discard!

      expect(subscription).to be_discarded
      expect(subscription.reload.discarded_at).to be_present
    end

    it 'raises at the database level when a second active row is forced past validations' do
      subscription = Fabricate(:subscription)
      duplicate = Fabricate.build(:subscription, member: subscription.member, group: subscription.group)

      # The partial unique index is the real enforcement; the validation is UX.
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'preserves the original created_at across undiscard' do
      subscription = Fabricate(:subscription, created_at: 2.years.ago)
      subscription.discard!
      subscription.undiscard!

      expect(subscription.reload.created_at).to be < 1.year.ago
      expect(subscription.reload.discarded_at).to be_nil
    end
  end

  describe 'history scopes' do
    it 'kept excludes tombstones while all includes them' do
      subscription = Fabricate(:subscription)
      tombstone = Fabricate(:discarded_subscription, member: Fabricate(:member),
                                                     group: subscription.group)

      expect(described_class.kept).not_to include(tombstone)
      expect(described_class.all).to include(tombstone, subscription)
    end
  end
end
