if Rails.env.development?
  begin
    puts 'Adding seed data...'
    chapters = [Fabricate(:chapter_with_groups, name: 'London'),
                Fabricate(:chapter_with_groups, name: 'Brighton'),
                Fabricate(:chapter_with_groups, name: 'Cambridge')]

    workshop = 10.times.map { |n| Fabricate(:workshop, title: 'Workshop', chapter: chapters.sample, date_and_time: Time.zone.now + 14.days - n.weeks) }
    workshop.concat 2.times.map { |n| Fabricate(:workshop, title: 'Workshop', chapter: chapters.sample) }

    event = 10.times.map { |n| Fabricate(:event, name: 'Event', date_and_time: Time.zone.now + 14.days - n.weeks) }
    event.concat 2.times.map { |n| Fabricate(:event, name: 'Event') }

    course = 10.times.map { |n| Fabricate(:course, chapter: chapters.sample, title: 'Course', date_and_time: Time.zone.now + 14.days - n.weeks) }
    course.concat 2.times.map { |n| Fabricate(:course, chapter: chapters.sample, title: 'Course') }

    meeting = 10.times.map { |n| Fabricate(:meeting, name: 'Meeting', date_and_time: Time.zone.now + 14.days - n.weeks) }
    meeting.concat 2.times.map { |n| Fabricate(:meeting, name: 'Meeting') }

    coaches = 20.times.map { |n| Fabricate(:coach, groups: Group.coaches.order('RANDOM()').limit(2)) }
    tutorials = 10.times.map { |n| Fabricate(:tutorial, workshop: workshop.sample) }
    feedback_requests = 5.times.map { Fabricate(:feedback_request) }
    feedbacks = 5.times.map { Fabricate(:feedback, tutorial: tutorials.sample, coach: coaches.sample) }

    job_titles = [
      'Software Engineer',
      'Software Developer',
      'Front-end Developer',
      'Back-end Developer',
      'Full-stack Developer'
    ]

    job_companies = [
      'ACME',
      'Globex',
      'Soylent',
      'Initech',
      'Umbrella',
      'Wonka'
    ]

    jobs = 5.times.map { Fabricate(:job, title: job_titles.sample, company: job_companies.sample) }

    40.times do |n|
      coach = coaches.sample
      Fabricate(:attended_workshop_invitation, role: 'Coach', member: coach, workshops: workshop.sample) rescue 'Coach already attended'
    end

    puts '..done!'
  rescue => e
    puts e.inspect
    puts 'Something went wrong. Try running `bundle exec rake db:drop db:create db:migrate` first'
  end
end
