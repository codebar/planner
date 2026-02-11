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
    attrs = member_params

    unless how_you_found_us_selections_valid?(attrs)
      @member.errors.add(:how_you_found_us, 'You must select one option')
      return render :edit
    end

    attrs[:how_you_found_us_other_reason] = nil if attrs[:how_you_found_us] != 'other'

    return render :edit unless @member.update(attrs)

    attrs[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end
end
