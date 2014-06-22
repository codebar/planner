module Invitable
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods

    def attendances
      invitations.accepted
    end

    def attending_students
      invitations.where(role: "Student").accepted.order('updated_at asc')
    end

    def attending_coaches
      invitations.where(role: "Coach").accepted.order('updated_at asc')
    end

  end
end
