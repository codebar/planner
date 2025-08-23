module MemberConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    private

    def member_params
      params.fetch(:member, {}).permit(
        :pronouns,
        :name,
        :surname,
        :email,
        :mobile,
        :about_you,
        :skill_list,
        :newsletter,
        :other_reason,
        how_you_found_us: []
      )
    end

    def suppress_notices
      @suppress_notices = true
    end

    def set_member
      @member = current_user
    end
  end
end
