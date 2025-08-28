class Member::DetailsController < ApplicationController
  include MemberConcerns
  include MailingListConcerns

  before_action :set_member
  before_action :suppress_notices
  before_action :is_logged_in?, only: %i[edit]

  def edit
    accept_terms
    flash[notice] = I18n.t('notifications.signing_up')
    @member.newsletter ||= true
  end

  def update
    if how_you_found_us_selections.blank?
      @member.assign_attributes(member_params_without_how_you_found_us_other_reason)
      @member.errors.add(:how_you_found_us, 'You must select at least one option')
      return render :edit
    end

    attrs = member_params_without_how_you_found_us_other_reason
    attrs[:how_you_found_us] = how_you_found_us_selections

    return render :edit unless @member.update(attrs)

    member_params[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end
end
