if Rails.env.development?
  begin
    puts "Adding seed data..."
    chapters = [Fabricate(:chapter_with_groups, name: "London"),
                Fabricate(:chapter_with_groups, name: "Brighton"),
                Fabricate(:chapter_with_groups, name: "Cambridge")]

    sessions = 10.times.map { |n| Fabricate(:sessions, chapter: chapters.sample, date_and_time: DateTime.now+14.days-n.weeks) }

    courses = 5.times.map { |n| Fabricate(:course, chapter: chapters.sample, date_and_time: DateTime.now+14.days-n.weeks) }
    coaches = 20.times.map { |n| Fabricate(:coach, groups: Group.coaches.order("RANDOM()").limit(2)) }
    tutorials = 10.times.map { |n| Fabricate(:tutorial, sessions: sessions.sample) }
    feedback_requests = 5.times.map { Fabricate(:feedback_request) }
    feedbacks = 5.times.map { Fabricate(:feedback, tutorial: tutorials.sample, coach: coaches.sample) }

    40.times do |n|
      coach = coaches.sample
      Fabricate(:attended_session_invitation, role: "Coach", member: coach, sessions: sessions.sample )  rescue "Coach already attended"
    end

    puts "..done!"
  rescue Exception => e
    puts e.inspect
    puts "Something went wrong. Try running `bundle exec rake db:drop db:create db:migrate` first"
  end
end
