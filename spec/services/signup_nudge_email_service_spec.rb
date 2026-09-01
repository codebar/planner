RSpec.describe SignupNudgeEmailService, type: :service do
  describe '#send_nudges' do
    subject(:call) { described_class.send_nudges }

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
    let!(:too_old) { Fabricate(:member, created_at: 3.weeks.ago) }
    let!(:recently_nudged) { Fabricate(:member, created_at: 10.days.ago) }
    let!(:completed_sequence) { Fabricate(:member, created_at: 7.weeks.ago) }
    let!(:subscribed_after_nudge) { Fabricate(:member, created_at: 6.weeks.ago) }

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
    end

    it 'nudges members created 7-14 days ago who have no subscription' do
      expect { perform_enqueued_jobs { call } }
        .to change { MemberEmailDelivery.where(member: nudge_eligible, email_type: 'signup_nudge').count }
        .by(1)
    end

    it 'sends the follow-up to members nudged more than a month ago' do
      expect { perform_enqueued_jobs { call } }
        .to change {
          MemberEmailDelivery.where(member: followup_eligible, email_type: 'signup_nudge_followup').count
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

    it 'does not nudge members younger than 7 days' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: too_young).count })
    end

    it 'does not nudge members older than 14 days without a nudge row' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: too_old).count })
    end

    it 'does not re-nudge a member already nudged' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: recently_nudged, email_type: 'signup_nudge').count })
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
  end
end
