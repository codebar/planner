class Member::DetailsController < ApplicationController
  include MemberConcerns
  include MailingListConcerns

  before_action :set_member
  before_action :suppress_notices

  def edit
    accept_terms

    flash[notice] = I18n.t('notifications.signing_up')
    @member.newsletter ||= true
  end

  def update
    return render :edit unless @member.update(member_params)

    member_params[:newsletter] ? subscribe_to_newsletter(@member) : unsubscribe_from_newsletter(@member)
    redirect_to step2_member_path
  end
end
