namespace :feedback do
  desc 'Request feedback from students that attended our latest workshop'
  task request: :environment do
    workshops = Workshop.completed_since_yesterday
    Rails.logger.info 'Sending Feedback request emails' if workshops.any?
    workshops.each do |workshop|
      WorkshopInvitation.accepted.where(workshop: workshop, role: 'Student').each do |invitation|
        feedback_request = FeedbackRequest.create(member: invitation.member, workshop: workshop, submited: false)
        FeedbackRequestMailer.request_feedback(workshop, invitation.member, feedback_request).deliver_now
      end
      Rails.logger.info "Feedback requests sent for #{workshop.chapter.name}'s #{workshop}: \
                         #{FeedbackRequest.where(workshop: workshop).count}"
    end
  end
end
