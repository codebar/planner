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
    attrs = member_params.to_h

    how_found = params.dig(:member, :how_you_found_us)
    attrs[:how_you_found_us] =
      if how_found.is_a?(Array)
        how_found
      elsif how_found.blank?
        []
      else
        [how_found]
      end

    if params[:other_reason].present?
      attrs[:how_you_found_us] << params[:other_reason]
    end

    attrs[:how_you_found_us].uniq!
    attrs[:how_you_found_us].reject!(&:blank?)

    return render :edit unless @member.update(attrs)

    member_params[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end
end
