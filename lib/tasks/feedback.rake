namespace :feedback do
  desc "Request feedback from students that attendanted last session"

  task request: :environment do
    raise 'Sorry. No recent sessions found.' if Sessions.most_recent.nil?

    STDOUT.print "Do you want to send feedback requests for session: #{Sessions.most_recent.title}? (y/N) "
    
    if STDIN.gets.chomp == 'y'
      STDOUT.puts "Sending feedback requests to:"
      Sessions.most_recent.invitations.attended.each do |invitation|
        STDOUT.puts "#{invitation.member.full_name} <#{invitation.member.email}>"
        FeedbackRequest.create(member: invitation.member, sessions: invitation.sessions, submited: false)
      end

      STDOUT.puts "\nTotal requests sent: #{Sessions.most_recent.invitations.attended.count}"
    end
  end
end
