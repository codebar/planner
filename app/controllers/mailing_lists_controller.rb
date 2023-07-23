class MailingListsController < ApplicationController
  include MailingListConcerns

  before_action :has_access?

  def create
    subscribe_to_newsletter(current_user)
    flash[:notice] = I18n.t('subscriptions.messages.mailing_list.subscribe')

    redirect_back fallback_location: root_path
  end

  def destroy
    unsubscribe_from_newsletter(current_user)
    flash[:notice] = I18n.t('subscriptions.messages.mailing_list.unsubscribe')

    redirect_back fallback_location: root_path
  end
end
