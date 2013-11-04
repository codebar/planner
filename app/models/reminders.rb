class Reminders < ActiveRecord::Base

  scope :session, ->(session) { where(reminder_type: "session", reminder_id: session.id) }

  def self.add_for_session session, count
    Reminders.create reminder_type: "session", reminder_id: session.id, count: count
  end
end
