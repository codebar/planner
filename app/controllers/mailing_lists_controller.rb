class MailingListsController < ApplicationController
  include MailingListConcerns

  before_action :has_access?

  def create
    subscribe_to_newsletter(current_user)
    flash[:notice] = 'You have subscribed to codebar''s newsletter'

    redirect_to :back
  end

  def destroy
    unsubscribe_from_newsletter(current_user)
    flash[:notice] = 'You have unsubscribed from codebar''s newsletter'

    redirect_to :back
  end
end
