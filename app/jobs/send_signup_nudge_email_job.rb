# frozen_string_literal: true

class SendSignupNudgeEmailJob < ApplicationJob
  queue_as :default

  def perform
    SignupNudgeEmailService.send_nudges
  end
end
