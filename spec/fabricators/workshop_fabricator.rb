Fabricator(:workshop) do
  date_and_time Time.zone.now + 2.days
  ends_at Time.zone.now + 2.days + 2.hours
  chapter
  after_build do |workshop, transients|
    Fabricate(:workshop_sponsor,
              workshop: workshop,
              sponsor: Fabricate(:sponsor,
                                 seats: transients[:student_count] || 10,
                                 number_of_coaches: transients[:coach_count || 10]),
              host: true)
  end

  transient :student_count
  transient :coach_count
end

Fabricator(:virtual_workshop, class_name: :workshop) do
  date_and_time Time.zone.now + 2.days
  ends_at Time.zone.now + 2.days + 2.hours
  chapter
  virtual true
  student_spaces 10
  coach_spaces 10
  slack_channel 'a-channel'
  slack_channel_link 'https://codebar.slack.link'
  after_build do |workshop|
    Fabricate(:workshop_sponsor, workshop: workshop, sponsor: Fabricate(:sponsor), host: false)
  end
end

Fabricator(:workshop_no_sponsor, class_name: :workshop) do
  date_and_time Time.zone.now + 2.days
  ends_at Time.zone.now + 2.days + 2.hours
  chapter
end

Fabricator(:workshop_auto_rsvp_in_past, from: :workshop) do
  rsvp_opens_at Time.zone.now - 1.day
  invitable false
end

Fabricator(:workshop_auto_rsvp_in_future, from: :workshop) do
  rsvp_opens_at Time.zone.now + 1.day
  invitable false
end

Fabricator(:past_workshop, from: :workshop) do
  date_and_time 3.months.ago
  ends_at 3.months.ago + 2.hours
end
