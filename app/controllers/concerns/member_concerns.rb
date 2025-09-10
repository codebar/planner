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
        :how_you_found_us_other_reason,
        how_you_found_us: []
      )
    end

    def suppress_notices
      @suppress_notices = true
    end

    def set_member
      @member = current_user
    end

    def how_you_found_us_selections
      how_found = Array(member_params[:how_you_found_us]).reject(&:blank?)
      other_reason = member_params[:how_you_found_us_other_reason]

      how_found << other_reason if other_reason.present?
      how_found.uniq!

      how_found
    end

    def member_params_without_how_you_found_us_other_reason
      member_params.to_h.except(:how_you_found_us_other_reason)
    end
  end
end
