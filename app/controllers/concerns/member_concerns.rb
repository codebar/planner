module MemberConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    private

    def member_params
      params.expect(member: [
        :pronouns, :name, :surname, :email, :mobile, :about_you, :skill_list, :newsletter, :other_dietary_restrictions, :how_you_found_us,
        :how_you_found_us_other_reason, { dietary_restrictions: [] }
      ]).tap do |permitted_params|
        # We want to keep Rails' hidden blank field in the form so that all dietary restrictions for a member can be
        # removed by submitting the form with all check boxes unticked. However, we want to remove the blank value
        # before setting the dietary restrictions attribute on the model.
        # See Gotcha section here:
        # https://api.rubyonrails.org/v7.1/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_check_boxes
        if permitted_params[:dietary_restrictions]
          permitted_params[:dietary_restrictions] = permitted_params[:dietary_restrictions].reject(&:blank?)
        end
      end
    end

    def suppress_notices
      @suppress_notices = true
    end

    def set_member
      @member = current_user
    end

    def how_you_found_us_selections_valid?(attrs)
      how_found_present = attrs[:how_you_found_us].present?
      other_reason_present = attrs[:how_you_found_us_other_reason].present?
      return false if attrs[:how_you_found_us] == 'other' && !other_reason_present
      return true if attrs[:how_you_found_us] == 'other' && other_reason_present

      how_found_present != other_reason_present
    end
  end
end
