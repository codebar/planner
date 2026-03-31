if Rails.env.development?
  # Check for ImageMagick before seeding
  imagemagick_available = system('convert --version > /dev/null 2>&1') ||
                          system('magick --version > /dev/null 2>&1')

  unless imagemagick_available
    Rails.logger.error '=' * 80
    Rails.logger.error 'ERROR: ImageMagick is required to run db:seed'
    Rails.logger.error '=' * 80
    Rails.logger.error ''
    Rails.logger.error 'The seed task processes sponsor logo images, which requires ImageMagick.'
    Rails.logger.error ''
    Rails.logger.error 'Install ImageMagick:'
    Rails.logger.error '  macOS:         brew install imagemagick'
    Rails.logger.error '  Ubuntu/Debian: apt-get install imagemagick'
    Rails.logger.error '  Windows:       https://imagemagick.org/script/download.php'
    Rails.logger.error ''
    Rails.logger.error 'See native-installation-instructions.md for details.'
    Rails.logger.error '=' * 80
    exit 1
  end

  begin
    Rails.logger.info 'Running migrations...'
    Rails.application.config.log_level = :info
    Rails.logger.info 'Creating chapters...'
    chapters = ['London', 'Brighton', 'Cambridge', 'Barcelona', 'Paris', 'Merlbourne', 'Berlin',
                'New York'].map do |name|
      Fabricate(:chapter_with_groups, name: name)
    end

    Rails.logger.info 'Creating workshops...'

    Rails.logger.info 'Creating 1000 past workshops...'
    past_workshops = []
    1000.times do
      months_ago = rand(0..60)
      start = Time.zone.now - months_ago.months + rand(0..28).days + rand(0..23).hours
      workshop = Fabricate(:workshop,
                           title: 'Workshop',
                           chapter: chapters.sample,
                           date_and_time: start,
                           ends_at: start + 3.hours)
      past_workshops << workshop
    end

    Rails.logger.info 'Creating 100 future workshops...'
    future_workshops = []
    100.times do
      months_ahead = rand(1..3)
      start = Time.zone.now + months_ahead.months + rand(0..28).days + rand(0..23).hours
      workshop = Fabricate(:workshop,
                           title: 'Workshop',
                           chapter: chapters.sample,
                           date_and_time: start,
                           ends_at: start + 3.hours)
      future_workshops << workshop
    end

    future_workshops.first(10)

    Rails.logger.info 'Creating events...'
    events = 20.times.map do |n|
      Fabricate(:event, name: 'Event',
                        chapters: chapters.sample(4),
                        date_and_time: Time.zone.now + 2.months - n.months)
    end

    Rails.logger.info 'Creating meetings...'

    20.times.map do |n|
      Fabricate(:meeting, name: 'Meeting',
                          date_and_time: Time.zone.now + 1.month - n.months)
    end

    Rails.logger.info 'Creating coaches...'
    coaches_group = Group.coaches.to_a
    students_group = Group.students.to_a
    coaches = 500.times.map { Fabricate(:coach, groups: coaches_group.sample(2)) }
    tutorials = Fabricate.times(20, :tutorial)
    30.times { Fabricate(:feedback_request, workshop: past_workshops.sample) }
    20.times { Fabricate(:feedback, tutorial: tutorials.sample, coach: coaches.sample) }
    10.times { Fabricate(:testimonial, member: coaches.sample) }

    # Add skills to some coaches using acts_as_taggable_on
    skill_lists = [
      'javascript, ruby, rails',
      'python, django, sql',
      'react, typescript, node',
      'java, spring, kotlin',
      'css, html, bootstrap',
      'go, kubernetes, docker',
      'c++, rust, systems',
      'swift, ios, android',
      'php, laravel, mysql',
      'git, linux, devops'
    ]

    coaches.each do |coach|
      next if rand > 0.7 # 70% of coaches get skills

      coach.skill_list.add(skill_lists.sample(rand(1..4)).split(', '))
      coach.save(validate: false)
    end

    Rails.logger.info 'Creating students...'
    students = 500.times.map { Fabricate(:student, groups: students_group.sample(2)) }

    Rails.logger.info 'Creating event invitations...'
    10.times do |_n|
      Fabricate(:invitation, member: students.sample, event: events.sample)
      Fabricate(:coach_invitation, member: coaches.sample, event: events.sample)
    end

    Rails.logger.info 'Creating workshop invitations for past workshops...'
    past_workshops.each do |workshop|
      invitation_count = rand(8..15)
      invitation_count.times do
          Fabricate(:coach_workshop_invitation, member: coaches.sample, workshop: workshop)
      rescue StandardError
          nil
      end
      invitation_count.times do
          Fabricate(:student_workshop_invitation, member: students.sample, workshop: workshop)
      rescue StandardError
          nil
      end

      # Create some attended invitations so coaches appear on wall_of_fame
      # Track which coaches already have invitations to avoid duplicates
      existing_invitees = WorkshopInvitation.where(workshop: workshop, role: 'Coach').pluck(:member_id)
      available_coaches = coaches.reject { |c| existing_invitees.include?(c.id) }
      rand(3..8).times do
        break if available_coaches.empty?

        coach = available_coaches.sample
        available_coaches.delete(coach)
        Fabricate(:attended_coach, member: coach, workshop: workshop)
      rescue StandardError
        nil
      end
    end

    Rails.logger.info 'Creating workshop invitations for future workshops...'
    future_workshops.each do |workshop|
      invitation_count = rand(10..20)
      invitation_count.times do
          Fabricate(:coach_workshop_invitation, member: coaches.sample, workshop: workshop)
      rescue StandardError
          nil
      end
      invitation_count.times do
          Fabricate(:student_workshop_invitation, member: students.sample, workshop: workshop)
      rescue StandardError
          nil
      end
    end
    Rails.logger.info '..done!'

    Rails.logger.info 'Creating invitation logs...'

    # Get organizers as initiators (or create one if none exist)
    organisers = Member.joins(:roles).where(roles: { name: 'organiser' }).to_a
    if organisers.empty?
      organisers << Fabricate(:member, name: 'Chapter', surname: 'Organiser')
    end

    realistic_failure_reasons = [
      'SMTP connection timeout',
      'Invalid email format: malformed address',
      'Rate limit exceeded: too many recipients',
      'Recipient mailbox full',
      'Connection refused by mail server',
      'DNS lookup failed for recipient domain'
    ].freeze

    # Filter to recent past workshops (last 3 months)
    recent_past_workshops = past_workshops.select do |w|
      w.date_and_time > 3.months.ago
    end

    # Create logs for ~25 recent workshops
    recent_past_workshops.sample(25).each do |workshop|
      initiator = organisers.sample
      audience = %w[students coaches everyone].sample

      # Determine invitee pool based on audience
      potential_invitees = case audience
                           when 'students' then students
                           when 'coaches' then coaches
                           else students + coaches
      end.sample(50)

      # Simulate realistic distribution
      total_to_invite = rand(15..potential_invitees.length)
      skipped_count = rand(0..(total_to_invite * 0.1).to_i)
      actual_sent = total_to_invite - skipped_count
      success_count = rand((actual_sent * 0.85).to_i..actual_sent)
      failure_count = actual_sent - success_count

      log = InvitationLog.create!(
        loggable: workshop,
        initiator: initiator,
        chapter: workshop.chapter,
        audience: audience,
        action: 'invite',
        status: 'completed',
        total_invitees: total_to_invite,
        success_count: success_count,
        failure_count: failure_count,
        skipped_count: skipped_count,
        started_at: workshop.date_and_time - 2.hours,
        completed_at: workshop.date_and_time - 1.hour + rand(0..30).minutes,
        expires_at: 180.days.from_now
      )

      # Get actual members for entries
      invitees = potential_invitees.sample(total_to_invite)
      skipped_members = invitees.shift(skipped_count)
      sent_members = invitees

      # Create skipped entries
      skipped_members.each do |member|
        InvitationLogEntry.create!(
          invitation_log: log,
          member: member,
          status: 'skipped',
          failure_reason: 'Invitation already exists',
          processed_at: log.started_at + rand(1..10).seconds
        )
      end

      # Create success entries
      success_members = sent_members.sample(success_count)
      success_members.each do |member|
        invitation = WorkshopInvitation.where(workshop: workshop, member: member).first
        InvitationLogEntry.create!(
          invitation_log: log,
          member: member,
          invitation: invitation,
          status: 'success',
          processed_at: log.started_at + rand(10..120).seconds
        )
      end

      # Create failure entries
      failure_members = sent_members - success_members
      failure_members.each do |member|
        InvitationLogEntry.create!(
          invitation_log: log,
          member: member,
          status: 'failed',
          failure_reason: realistic_failure_reasons.sample,
          processed_at: log.started_at + rand(10..120).seconds
        )
      end
    end

    # Create 2 running (in-progress) logs for future workshops
    future_workshops.sample(2).each do |workshop|
      initiator = organisers.sample
      audience = %w[students coaches everyone].sample

      log = InvitationLog.create!(
        loggable: workshop,
        initiator: initiator,
        chapter: workshop.chapter,
        audience: audience,
        action: 'invite',
        status: 'running',
        total_invitees: 0,
        success_count: 0,
        failure_count: 0,
        skipped_count: 0,
        started_at: Time.current - rand(5..30).minutes,
        expires_at: 180.days.from_now
      )

      # Create a few in-progress entries
      potential_invitees = case audience
                           when 'students' then students
                           when 'coaches' then coaches
                           else students + coaches
      end.sample(20)

      potential_invitees.sample(rand(3..8)).each do |member|
        InvitationLogEntry.create!(
          invitation_log: log,
          member: member,
          status: 'success',
          processed_at: log.started_at + rand(60..300).seconds
        )
        log.update_column(:success_count, log.success_count + 1)
      end
    end

    Rails.logger.info '..done creating invitation logs!'
  rescue Exception => e
    Rails.logger.error 'Something went wrong. Try running `bundle exec rake db:drop db:create db:migrate` first'
    Rails.logger.error e.message
  end
end
