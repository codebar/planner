module MemberConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    private

    def member_params
      params.require(:member).permit(
        :pronouns, :name, :surname, :email, :mobile, :about_you, :skill_list, :newsletter, :other_dietary_restrictions,
          dietary_restrictions: [],
      ).tap do |params|
        params[:dietary_restrictions] = params[:dietary_restrictions].reject(&:blank?) if params[:dietary_restrictions]
      end
    end

    def suppress_notices
      @suppress_notices = true
    end

    def set_member
      @member = current_user
    end
  end
end
