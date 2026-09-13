class MailingListsController < ApplicationController
  include MailingListConcerns

  before_action :require_access

  def create
    MemberActivityRecorder.record(actor: current_user, key: 'mailing_list.subscribe')
    subscribe_to_newsletter(current_user)
    flash[:notice] = I18n.t('subscriptions.messages.mailing_list.subscribe')

    redirect_back fallback_location: root_path
  end

  def destroy
    MemberActivityRecorder.record(actor: current_user, key: 'mailing_list.unsubscribe')
    unsubscribe_from_newsletter(current_user)
    flash[:notice] = I18n.t('subscriptions.messages.mailing_list.unsubscribe')

    redirect_back fallback_location: root_path
  end
end
