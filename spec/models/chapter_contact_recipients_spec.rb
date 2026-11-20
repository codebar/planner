require 'rails_helper'

RSpec.describe Chapter do
  let(:chapter) { Fabricate(:chapter) }
  let(:student_group) { Fabricate(:group, chapter:, name: 'Students') }
  let(:coach_group) { Fabricate(:group, chapter:, name: 'Coaches') }

  def subscribe(member, group)
    Fabricate(:subscription, member:, group:)
  end

  def record_activity(member, at:)
    PublicActivity::Activity.create!(
      owner: member, trackable: member, key: 'test.activity', created_at: at, updated_at: at
    )
  end

  describe '#contact_recipients' do
    it 'returns distinct current chapter members for a selected custom list' do
      member = Fabricate(:member)
      subscribe(member, student_group)
      subscribe(member, coach_group)
      former_member = Fabricate(:member)
      Fabricate(:discarded_subscription, member: former_member, group: student_group)
      outsider = Fabricate(:member)

      expect(chapter.contact_recipients('custom_list', [member.id, former_member.id, outsider.id]))
        .to contain_exactly(member)
    end

    it 'filters activity against the selected period and only current chapter members' do
      active_member = Fabricate(:member)
      inactive_member = Fabricate(:member)
      unsubscribed_member = Fabricate(:member)
      subscribe(active_member, student_group)
      subscribe(inactive_member, student_group)
      Fabricate(:discarded_subscription, member: unsubscribed_member, group: student_group)
      record_activity(active_member, at: 2.weeks.ago)
      record_activity(inactive_member, at: 2.months.ago)
      record_activity(unsubscribed_member, at: 2.weeks.ago)

      expect(chapter.contact_recipients('active_last_month', activity_months: '1')).to contain_exactly(active_member)
      expect(chapter.contact_recipients('inactive_last_month', activity_months: '1'))
        .to contain_exactly(inactive_member)
      expect(chapter.contact_recipients('active_last_month', activity_months: '9')).to be_empty
    end

    it 'matches RSVP statuses only for current members of events linked to the chapter' do
      event = Fabricate(:event, chapters: [chapter])
      members = {
        'attending' => Fabricate(:member),
        'declined' => Fabricate(:member),
        'unanswered' => Fabricate(:member)
      }
      members.each do |status, member|
        subscribe(member, student_group)
        Fabricate(:invitation, event:, member:, attending: { 'attending' => true, 'declined' => false }[status])
      end

      other_event = Fabricate(:event)
      outsider = Fabricate(:member)
      Fabricate(:invitation, event: other_event, member: outsider, attending: true)
      other_chapter_member = Fabricate(:member)
      subscribe(other_chapter_member, Fabricate(:group, chapter: Fabricate(:chapter), name: 'Students'))
      Fabricate(:invitation, event:, member: other_chapter_member, attending: true)

      expect(chapter.contact_recipients('event_rsvp', event_id: event.id, rsvp_status: 'attending'))
        .to contain_exactly(members.fetch('attending'))
      expect(chapter.contact_recipients('event_rsvp', event_id: event.id, rsvp_status: 'declined'))
        .to contain_exactly(members.fetch('declined'))
      expect(chapter.contact_recipients('event_rsvp', event_id: event.id, rsvp_status: 'unanswered'))
        .to contain_exactly(members.fetch('unanswered'))
      expect(chapter.contact_recipients('event_rsvp', event_id: other_event.id, rsvp_status: 'attending')).to be_empty
      expect(chapter.contact_recipients('event_rsvp', event_id: event.id, rsvp_status: 'unknown')).to be_empty
    end

    it 'deduplicates chapter and linked-event organisers and excludes other events' do
      chapter_organiser = Fabricate(:member)
      chapter_organiser.add_role(:organiser, chapter)
      chapter_organiser.add_role(:organiser, Fabricate(:event, chapters: [chapter]))
      event_organiser = Fabricate(:member)
      event_organiser.add_role(:organiser, Fabricate(:event, chapters: [chapter]))
      unrelated_organiser = Fabricate(:member)
      unrelated_organiser.add_role(:organiser, Fabricate(:event))

      expect(chapter.contact_recipients('leadership_team')).to contain_exactly(chapter_organiser, event_organiser)
    end

    it 'returns no recipients for unsupported audiences' do
      expect(chapter.contact_recipients('not_an_audience')).to be_empty
    end
  end
end
