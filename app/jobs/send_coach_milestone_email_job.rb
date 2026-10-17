# frozen_string_literal: true

class SendCoachMilestoneEmailJob < ApplicationJob
  queue_as :default

  def perform
    CoachMilestoneEmailService.send_milestone_emails
  end
end
