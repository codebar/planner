module MemberConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    private

    def member_params
      params.require(:member).permit(
        :pronouns, :name, :surname, :email, :mobile, :twitter, :about_you, :skill_list, :newsletter
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
