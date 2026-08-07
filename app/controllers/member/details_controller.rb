class Member::DetailsController < ApplicationController
  include MemberConcerns
  include MailingListConcerns

  before_action :set_member
  before_action :suppress_notices
  before_action :require_login, only: %i[edit]

  def edit
    accept_terms
    if session.delete(:new_member)
      flash[notice] = I18n.t('notifications.signing_up')
    end
    @member.newsletter ||= true
  end

  def update
    attrs = member_params

    return render_with_all_errors(attrs) unless how_you_found_us_selections_valid?(attrs)

    attrs[:how_you_found_us_other_reason] = nil if attrs[:how_you_found_us] != 'other'

    return render :edit unless @member.update(attrs)

    @member.newsletter ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end

  private

  def render_with_all_errors(attrs)
    @member.assign_attributes(attrs)
    @member.valid?
    @member.errors.add(:how_you_found_us, 'You must select one option')
    render :edit
  end
end
