require 'rails_helper'

RSpec.describe CoachMilestoneEmailService do
  describe '.send_milestone_emails' do
    subject(:call) { described_class.send_milestone_emails }

    around do |example|
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      example.run
    ensure
      ActiveJob::Base.queue_adapter = original_adapter
    end

    def attend(member, count, role: 'Coach', weeks_ago: 1)
      count.times do |i|
        workshop = Fabricate(:workshop, chapter:, date_and_time: (weeks_ago + i).weeks.ago)
        Fabricate(:workshop_invitation, member:, workshop:, role:, attended: true)
      end
    end

    let(:chapter) { Fabricate(:chapter) }

    let!(:coach_at_five) { Fabricate(:member).tap { |m| attend(m, 5) } }
    let!(:coach_at_seven) { Fabricate(:member).tap { |m| attend(m, 7) } }
    let!(:coach_at_four) { Fabricate(:member).tap { |m| attend(m, 4) } }
    let!(:coach_with_future_fifth) do
      Fabricate(:member).tap do |m|
        attend(m, 4)
        Fabricate(:workshop_invitation, member: m, workshop: Fabricate(:workshop, chapter:), role: 'Coach',
                                        attended: true)
      end
    end
    let!(:coach_invited_not_attended) do
      Fabricate(:member).tap do |m|
        5.times do |i|
          Fabricate(:workshop_invitation, member: m, role: 'Coach', attending: true, attended: nil,
                                          workshop: Fabricate(:workshop, chapter:, date_and_time: (i + 1).weeks.ago))
        end
      end
    end
    let!(:student_at_five) { Fabricate(:member).tap { |m| attend(m, 5, role: 'Student') } }
    let!(:coach_already_thanked) do
      Fabricate(:member).tap do |m|
        attend(m, 5)
        Fabricate(:member_email_delivery, member: m, email_type: 'coach_milestone_5')
      end
    end
    let!(:coach_with_other_email_logged) do
      Fabricate(:member).tap do |m|
        attend(m, 5)
        Fabricate(:member_email_delivery, member: m, email_type: 'chaser')
      end
    end
    let!(:coach_thanked_for_higher_milestone) do
      Fabricate(:member).tap do |m|
        attend(m, 6)
        Fabricate(:member_email_delivery, member: m, email_type: 'coach_milestone_10')
      end
    end
    let!(:banned_coach) { Fabricate(:banned_member).tap { |m| attend(m, 5) } }
    let!(:coach_without_toc) { Fabricate(:member_without_toc).tap { |m| attend(m, 5) } }

    it 'thanks coaches who attended at least five past workshops and were not thanked before' do
      expect { perform_enqueued_jobs { call } }.to change(MemberEmailDelivery, :count).by(3)

      expect(MemberEmailDelivery.where(member: coach_at_five, email_type: 'coach_milestone_5')).to exist
      expect(MemberEmailDelivery.where(member: coach_at_seven, email_type: 'coach_milestone_5')).to exist
      expect(MemberEmailDelivery.where(member: coach_with_other_email_logged, email_type: 'coach_milestone_5'))
        .to exist
    end

    it 'does not thank a coach below the milestone' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: coach_at_four).count })
    end

    it 'does not count workshops that have not taken place yet' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: coach_with_future_fifth).count })
    end

    it 'does not count invitations that were accepted but not attended' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: coach_invited_not_attended).count })
    end

    it 'does not count workshops attended as a student' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: student_at_five).count })
    end

    it 'does not thank a coach twice for the same milestone' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: coach_already_thanked).count })
    end

    it 'does not thank a coach already thanked for a higher milestone' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: coach_thanked_for_higher_milestone).count })
    end

    it 'does not thank banned coaches' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: banned_coach).count })
    end

    it 'does not thank coaches who have not accepted the terms of conduct' do
      expect { perform_enqueued_jobs { call } }
        .not_to(change { MemberEmailDelivery.where(member: coach_without_toc).count })
    end

    it 'is idempotent across runs' do
      perform_enqueued_jobs { described_class.send_milestone_emails }

      expect { perform_enqueued_jobs { described_class.send_milestone_emails } }
        .not_to change(MemberEmailDelivery, :count)
    end

    context 'when a higher milestone is configured' do
      before { stub_const("#{described_class}::MILESTONES", [5, 10]) }

      let!(:coach_at_twelve) { Fabricate(:member).tap { |m| attend(m, 12) } }

      it 'sends only the highest milestone reached' do
        perform_enqueued_jobs { call }

        expect(MemberEmailDelivery.where(member: coach_at_twelve).pluck(:email_type)).to eq(['coach_milestone_10'])
      end
    end
  end
end
