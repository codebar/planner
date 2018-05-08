namespace :feedback do
  desc 'Request feedback from students that attended our latest workshop'

  task request: :environment do
    workshops = Workshop.completed_since_yesterday
    workshops.each do |workshop|
      Rails.logger.info "Sending emails for feedback requests for workshop at #{workshop.host.name}"
      WorkshopInvitation.accepted.where(workshop: workshop, role: 'Student').map do |invitation|
        FeedbackRequest.create(member: invitation.member, workshop: workshop, submited: false)
      end
      Rails.logger.info "Feedback requests sent: #{FeedbackRequest.where(workshop: workshop).select('count()')}"
    end
  end
end
