# frozen_string_literal: true

class SendThreeMonthEmailJob < ApplicationJob
  queue_as :default

  def perform
    ThreeMonthEmailService.send_chaser
  end
end
