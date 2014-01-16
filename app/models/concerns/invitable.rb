module Invitable
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods

    def attending_students
      invitations.where(role: "Student").accepted
    end

    def attending_coaches
      invitations.where(role: "Coach").accepted
    end

  end
end
