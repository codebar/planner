module Invitable
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    def attendances
      invitations.accepted
                 .includes(:member)
                 .joins(:member).merge Member.not_banned
    end

    def attending_students
      attendances.where(role: 'Student').order('members.name, members.surname')
    end

    def attending_coaches
      attendances.where(role: 'Coach').order('members.name, members.surname')
    end
  end
end
