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
      invitations.where(role: 'Student').accepted.includes(:member).order('members.name, members.surname')
    end

    def attending_coaches
      invitations.where(role: 'Coach').accepted.includes(:member).order('members.name, members.surname')
    end
  end
end
