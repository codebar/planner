module MemberConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    private

    def member_params
      params.require(:member).permit(
        :pronouns, :name, :surname, :email, :mobile, :about_you, :skill_list, :newsletter, :other_dietary_restrictions, :other_reason,  :how_you_found_us_other_reason, how_you_found_us: [], dietary_restrictions: [] 
      ).tap do |params|
        # We want to keep Rails' hidden blank field in the form so that all dietary restrictions for a member can be
        # removed by submitting the form with all check boxes unticked. However, we want to remove the blank value
        # before setting the dietary restrictions attribute on the model.
        # See Gotcha section here:
        # https://api.rubyonrails.org/v7.1/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_check_boxes
        params[:dietary_restrictions] = params[:dietary_restrictions].reject(&:blank?) if params[:dietary_restrictions]
      end
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
