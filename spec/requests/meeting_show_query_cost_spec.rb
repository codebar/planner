require 'rails_helper'

RSpec.describe 'Meeting show query cost' do
  # Regression guard for the attendee list on /meetings/:slug:
  # each attendee's member must be eager-loaded, so the SQL cost of the
  # page must not grow per rendered attendee.

  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do
      queries += 1
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  it 'does not add per-attendee queries as attendees join' do
    meeting = Fabricate(:meeting)
    3.times { Fabricate(:attending_meeting_invitation, meeting:) }

    get "/meetings/#{meeting.slug}"
    few_attendees = count_queries { get "/meetings/#{meeting.slug}" }

    15.times { Fabricate(:attending_meeting_invitation, meeting:) }

    many_attendees = count_queries { get "/meetings/#{meeting.slug}" }

    expect(many_attendees).to be <= few_attendees + 3
  end
end
