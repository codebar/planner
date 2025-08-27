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
    how_found = Array(params.dig(:member, :how_you_found_us)).reject(&:blank?)
    other_reason = params.dig(:member, :how_you_found_us_other_reason)

    how_found << other_reason if other_reason.present?
    how_found.uniq!

    if how_found.blank?
      @member.assign_attributes(member_params.to_h.except(:how_you_found_us_other_reason))
      @member.errors.add(:how_you_found_us, 'You must select at least one option')
      return render :edit
    end

    attrs = member_params.to_h.except(:how_you_found_us_other_reason)
    attrs[:how_you_found_us] = how_found

    return render :edit unless @member.update(attrs)

    member_params[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end
end