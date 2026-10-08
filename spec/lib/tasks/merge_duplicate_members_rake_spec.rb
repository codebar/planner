# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake member:duplicates', type: :task do
  let(:cutoff) { MergeDuplicateMembers::CUTOFF_TIME }

  before do
    allow($stdout).to receive(:puts)
  end

  def create_member(email:, name:, surname: nil, created_at: nil)
    member = Member.new(email:, name:, surname:, about_you: 'n/a', accepted_toc_at: Time.zone.now)
    member.save(validate: false)
    member.update_columns(created_at:) if created_at
    member
  end

  def create_duplicate(email: 'dup@example.com', name: 'Sam', surname: 'Dup', uid: nil, created_at: cutoff + 1.day)
    member = create_member(email:, name:, surname:, created_at:)
    member.auth_services.create!(provider: 'codebar', uid: uid || email)
    member.reload
  end

  def create_original(email: 'orig@example.com', name: 'Sam', surname: 'Dup', created_at: cutoff - 1.day)
    member = create_member(email:, name:, surname:, created_at:)
    member.auth_services.create!(provider: 'github', uid: '1234567')
    member.reload
  end

  def merge!(dup, orig)
    MergeDuplicateMembers::Merger.new(
      MergeDuplicateMembers::Match.new(dup.id, orig.id, 'email'), dry_run: false
    ).call
  end

  describe 'member:duplicates:fix' do
    let(:task) { Rake::Task['member:duplicates:fix'] }

    after { task.reenable }

    it 'preloads the Rails environment' do
      expect(task.prerequisites).to include 'environment'
    end

    it 'changes nothing in dry-run mode' do
      dup = create_duplicate
      create_original
      old_email = dup.email

      task.execute

      expect(dup.reload.email).to eq(old_email)
      expect(dup.auth_services).not_to be_empty
    end
  end

  describe 'Merger member_email_deliveries' do
    it 'moves the duplicate delivery when the original has no delivery of that type' do
      dup = create_duplicate
      orig = create_original
      delivery = Fabricate(:member_email_delivery, member: dup, email_type: 'chaser')
      Fabricate(:member_email_delivery, member: orig, email_type: 'welcome')

      merge!(dup, orig)

      expect(delivery.reload.member_id).to eq(orig.id)
    end

    it 'keeps the duplicate delivery on the renamed member when the original already has that type' do
      dup = create_duplicate
      orig = create_original
      delivery = Fabricate(:member_email_delivery, member: dup, email_type: 'welcome')
      Fabricate(:member_email_delivery, member: orig, email_type: 'welcome')

      merge!(dup, orig)

      expect(delivery.reload.member_id).to eq(dup.id)
    end
  end

  describe 'Merger subscriptions' do
    it 'deletes the duplicate subscription when the original has an active one for the group' do
      dup = create_duplicate
      orig = create_original
      group = Fabricate(:group)
      Fabricate(:subscription, member: orig, group:)
      duplicate_subscription = Fabricate(:subscription, member: dup, group:)

      merge!(dup, orig)

      expect { duplicate_subscription.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'moves the duplicate active subscription when the original only has a discarded one' do
      dup = create_duplicate
      orig = create_original
      group = Fabricate(:group)
      Fabricate(:discarded_subscription, member: orig, group:)
      duplicate_subscription = Fabricate(:subscription, member: dup, group:)

      merge!(dup, orig)

      expect(duplicate_subscription.reload.member_id).to eq(orig.id)
      expect(duplicate_subscription.discarded_at).to be_nil
    end
  end

  describe 'Merger invitations' do
    it 'moves the duplicate invitation when the roles differ on the same event' do
      dup = create_duplicate
      orig = create_original
      event = Fabricate(:event)
      Fabricate(:coach_invitation, member: orig, event:)
      duplicate_invitation = Fabricate(:invitation, member: dup, event:)

      merge!(dup, orig)

      expect(duplicate_invitation.reload.member_id).to eq(orig.id)
    end

    it 'deletes the duplicate invitation when the original has the same event and role' do
      dup = create_duplicate
      orig = create_original
      event = Fabricate(:event)
      Fabricate(:invitation, member: orig, event:)
      duplicate_invitation = Fabricate(:invitation, member: dup, event:)

      merge!(dup, orig)

      expect { duplicate_invitation.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'Merger deactivation' do
    it 're-points the codebar auth service, renames the duplicate, and strips its services' do
      dup = create_duplicate
      orig = create_original
      old_uid = dup.auth_services.find_by(provider: 'codebar').uid

      merge!(dup, orig)

      expect(dup.reload.email).to eq("duplicate.#{dup.id}.merged-into.#{orig.id}@codebar.io")
      expect(dup.auth_services).to be_empty
      expect(orig.auth_services.where(provider: 'codebar').pluck(:uid)).to include(old_uid)
    end
  end

  describe 'Detector firstname_uid_surname_matches' do
    subject(:matches) do
      MergeDuplicateMembers::Detector.new.call.map do |match|
        [match.dup_member_id, match.original_member_id, match.merge_strategies]
      end
    end

    it 'does not match on first name alone when the original surname is blank' do
      create_duplicate(name: 'joana', surname: nil, uid: 'j.pocopkaite@gmail.com')
      create_original(name: 'Joana', surname: '', email: 'joana.afonso1@outlook.com')

      expect(matches).to be_empty
    end

    it 'matches when the original surname appears in the duplicate uid' do
      dup = create_duplicate(name: 'joana', surname: nil, uid: 'j.pocopkaite@gmail.com')
      orig = create_original(name: 'Joana', surname: 'Pocopkaite', email: 'joana.afonso1@outlook.com')

      expect(matches).to contain_exactly(
        [dup.id, orig.id, 'first-name+uid-surname']
      )
    end
  end
end
