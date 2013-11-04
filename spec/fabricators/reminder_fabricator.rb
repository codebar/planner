Fabricator(:reminders) do
  count 10
end

Fabricator(:session_reminder, from: :reminders) do
  reminder_type "session"
end
