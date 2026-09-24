# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignupNudgeEmailService, type: :service do
  describe '#send_nudges' do
    subject(:call) { described_class.send_nudges }

    def enqueued_nudge_recipients(action)
      ActiveJob::Base.queue_adapter.enqueued_jobs.filter_map do |job|
        mailer, mail_action, _delivery_method, options = job[:args]
        next unless mailer == 'MemberMailer' && mail_action == action.to_s

        options.dig('params', 'member', '_aj_globalid')
      end
    end

    def member_gid(member)
      "gid://planner/Member/#{member.id}"
    end

    around do |example|
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      example.run
    ensure
      ActiveJob::Base.queue_adapter = original_adapter
    end

    let!(:nudge_eligible) { Fabricate(:member, created_at: 10.days.ago) }
    let!(:followup_eligible) { Fabricate(:member, created_at: 6.weeks.ago) }
    let!(:subscribed_in_window) { Fabricate(:member, created_at: 10.days.ago) }
    let!(:banned_in_window) { Fabricate(:banned_member, created_at: 10.days.ago) }
    let!(:too_young) { Fabricate(:member, created_at: 2.days.ago) }
    let!(:too_old) { Fabricate(:member, created_at: 5.weeks.ago) }
    let!(:recently_nudged) { Fabricate(:member, created_at: 10.days.ago) }
    let!(:completed_sequence) { Fabricate(:member, created_at: 7.weeks.ago) }
    let!(:subscribed_after_nudge) { Fabricate(:member, created_at: 6.weeks.ago) }
    let!(:unsubscribed_after_signup) { Fabricate(:member, created_at: 10.days.ago) }
    let!(:unsubscribed_after_nudge) { Fabricate(:member, created_at: 6.weeks.ago) }

    before do
      Fabricate(:subscription, member: subscribed_in_window)
      Fabricate(:member_email_delivery, member: followup_eligible, email_type: 'signup_nudge',
                                        created_at: 5.weeks.ago)
      Fabricate(:member_email_delivery, member: recently_nudged, email_type: 'signup_nudge')
      Fabricate(:member_email_delivery, member: completed_sequence, email_type: 'signup_nudge',
                                        created_at: 6.weeks.ago)
      Fabricate(:member_email_delivery, member: completed_sequence, email_type: 'signup_nudge_followup',
                                        created_at: 5.weeks.ago)
      Fabricate(:member_email_delivery, member: subscribed_after_nudge, email_type: 'signup_nudge',
                                        created_at: 5.weeks.ago)
      Fabricate(:subscription, member: subscribed_after_nudge)
      Fabricate(:discarded_subscription, member: unsubscribed_after_signup,
                                         created_at: 9.days.ago, discarded_at: 1.day.ago)
      Fabricate(:member_email_delivery, member: unsubscribed_after_nudge, email_type: 'signup_nudge',
                                        created_at: 5.weeks.ago)
      Fabricate(:discarded_subscription, member: unsubscribed_after_nudge,
                                         created_at: 6.weeks.ago, discarded_at: 4.weeks.ago)
    end

    it 'nudges members created 7-14 days ago who have no subscription' do
      expect { perform_enqueued_jobs { call } }
        .to change { MemberEmailDelivery.where(member: nudge_eligible, email_type: 'signup_nudge').count }
        .by(1)
    end

    it 'sends the follow-up to members nudged more than a month ago' do
      expect { perform_enqueued_jobs { call } }
        .to change {
              MemberEmailDelivery.where(member: followup_eligible,
                                        email_type: 'signup_nudge_followup').count
            }
        .by(1)
    end

    it 'does not nudge subscribed members' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: subscribed_in_window).count })
    end

    it 'does not nudge banned members' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: banned_in_window).count })
    end

    it 'nudges members created 15-30 days ago who have no subscription' do
      older_eligible = Fabricate(:member, created_at: 20.days.ago)
      expect { perform_enqueued_jobs { call } }
        .to change { MemberEmailDelivery.where(member: older_eligible, email_type: 'signup_nudge').count }
        .by(1)
    end

    it 'does not nudge members younger than 7 days' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: too_young).count })
    end

    it 'does not nudge members older than 30 days without a nudge row' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: too_old).count })
    end

    it 'does not re-nudge a member already nudged' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: recently_nudged).count })
    end

    it 'does not send a follow-up while the nudge is less than a month old' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: recently_nudged, email_type: 'signup_nudge_followup').count })
    end

    it 'sends nothing further to members who completed the sequence' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: completed_sequence).count })
    end

    it 'does not send a follow-up to a member who has since subscribed' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change do
          MemberEmailDelivery.where(member: subscribed_after_nudge, email_type: 'signup_nudge_followup').count
        end)
    end

    # Regression for #2920: a member who subscribed and later unsubscribed has only a
    # tombstoned row. They must be ineligible for both the nudge and the follow-up.
    it 'does not nudge a member who subscribed and then unsubscribed' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: unsubscribed_after_signup, email_type: 'signup_nudge').count })
    end

    it 'does not send a follow-up to a member who subscribed and then unsubscribed' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change do
          MemberEmailDelivery.where(member: unsubscribed_after_nudge, email_type: 'signup_nudge_followup').count
        end)
    end

    # Regression for #2919: merge() dropped the delivery anti-join, re-emailing members daily.
    # Duplicate sends leave member_email_deliveries unchanged (find_or_create_by!), so these
    # assertions look at enqueued mailer jobs, which every duplicate send does enqueue.
    it 'does not enqueue a second nudge for a member already nudged' do
      expect { call }.not_to change { enqueued_nudge_recipients('signup_nudge').tally[member_gid(recently_nudged)] }.from(nil)
    end

    it 'does not enqueue a second follow-up for a member whose sequence completed' do
      expect { call }.not_to change { enqueued_nudge_recipients('signup_nudge_followup').tally[member_gid(completed_sequence)] }.from(nil)
    end

    it 'enqueues exactly one nudge per eligible member' do
      call
      expect(enqueued_nudge_recipients('signup_nudge').tally[member_gid(nudge_eligible)]).to eq(1)
    end

    it 'enqueues exactly one follow-up per followup-eligible member' do
      call
      expect(enqueued_nudge_recipients('signup_nudge_followup').tally[member_gid(followup_eligible)]).to eq(1)
    end

    # DB allows NULL member_id on both tables; one such row would make NOT IN exclude everyone
    it 'still sends nudges when log or subscription rows have no member_id' do
      Fabricate(:member_email_delivery, email_type: 'signup_nudge').update_column(:member_id, nil)
      Fabricate(:subscription).update_column(:member_id, nil)

      expect { perform_enqueued_jobs { call } }
        .to change { MemberEmailDelivery.where(member: nudge_eligible, email_type: 'signup_nudge').count }
        .by(1)
    end
  end
end
