if Rails.env.development?
  begin
    puts "Adding seed data..."
    chapters = [Fabricate(:chapter_with_groups, name: "London"),
                Fabricate(:chapter_with_groups, name: "Brighton"),
                Fabricate(:chapter_with_groups, name: "Cambridge")]

    sessions = 10.times.map { |n| Fabricate(:sessions, chapter: chapters.sample, date_and_time: Time.zone.now+14.days-n.weeks) }

    courses = 5.times.map { |n| Fabricate(:course, chapter: chapters.sample, date_and_time: Time.zone.now+14.days-n.weeks) }
    coaches = 20.times.map { |n| Fabricate(:coach, groups: Group.coaches.order("RANDOM()").limit(2)) }
    tutorials = 10.times.map { |n| Fabricate(:tutorial, sessions: sessions.sample) }
    feedback_requests = 5.times.map { Fabricate(:feedback_request) }
    feedbacks = 5.times.map { Fabricate(:feedback, tutorial: tutorials.sample, coach: coaches.sample) }

    40.times do |n|
      coach = coaches.sample
      Fabricate(:attended_session_invitation, role: "Coach", member: coach, sessions: sessions.sample )  rescue "Coach already attended"
    end

    meeting = Meeting.create(venue: Sponsor.all.shuffle.first,
                             date_and_time: Time.zone.now+1.year-11.months,
                             duration: 120,
                             lanyrd_url: "http://lanyrd.com/2013/by-codebar/")
    meeting.meeting_talks << MeetingTalk.create(title: "Becoming a Software Engineer",
                                                description: "Inspiring a New Generation of Developers",
                                                speaker_id: Member.first.id,
                                                abstract: Faker::Lorem.paragraph)

    meeting.meeting_talks << MeetingTalk.create(title: "Kickstart your development career",
                                                speaker_id: Member.last.id,
                                                abstract: Faker::Lorem.paragraph)
    puts "..done!"
  rescue Exception => e
    puts e.inspect
    puts "Something went wrong. Try running `bundle exec rake db:drop db:create db:migrate` first"
  end
end
