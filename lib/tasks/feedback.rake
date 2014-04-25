namespace :feedback do
  desc "Request feedback from students that attendanted last session"

  task request: :environment do
    raise 'Sorry. No recent sessions found.' if Sessions.most_recent.nil?

    STDOUT.print "Do you want to send feedback requests for workshop: #{I18n.l(Sessions.most_recent.date_and_time, format: :email_title)}? (y/N) "

    if STDIN.gets.chomp == 'y'
      STDOUT.puts "Sending feedback requests to:"
      latest_session = Sessions.most_recent
      latest_session.invitations.where(role: "Student").attended.map do |invitation|
        STDOUT.puts "#{invitation.member.full_name} <#{invitation.member.email}>"
        FeedbackRequest.create(member: invitation.member, sessions: invitation.sessions, submited: false)
      end

      STDOUT.puts "\nTotal requests sent: #{FeedbackRequest.where(sessions: latest_session).count}"
    end
  end
end
