# frozen_string_literal: true

module AttendanceConcerns
  extend ActiveSupport::Concern

  def attending_workshops
    current_user.nil? ? Set.new : current_user.workshop_invitations.accepted.pluck(:id).to_set
  end

  def attending_events
    current_user.nil? ? Set.new : current_user.invitations.accepted.pluck(:id).to_set
  end
end
