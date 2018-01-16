namespace :feedback do
  desc 'Request feedback from students that attended our last workshop'

  task request: :environment do
    workshop = Workshop.most_recent
    STDOUT.puts "Sending feedback requests for Workshop #{I18n.l(workshop.date_and_time, format: :date)}"

    if workshop.date_and_time < Time.zone.now + 12.hours
      workshop.invitations.where(role: 'Student').accepted.map do |invitation|
        STDOUT.puts "#{invitation.member.full_name} <#{invitation.member.email}>"
        FeedbackRequest.create(member: invitation.member, workshop: invitation.workshop, submited: false)
      end
      STDOUT.puts "\nTotal requests sent: #{FeedbackRequest.where(workshop: workshop).count}"

    end
  end
end
