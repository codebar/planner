class ContactPreferencesController < ApplicationController
  def show
    @contact = Contact.find_by(token: token)

    return if @contact

    flash[:notice] = I18n.t('messages.invalid_session')
  end

  def update
    contact = Contact.find_by(token: contact_preferences[:token])
    notice = I18n.t('messages.contact_preferences.updated')
    contact.update(mailing_list_consent: mailing_list_consent)

    redirect_to contact_preferences_path(token: contact_preferences[:token]), notice: notice
  end

  private

  def token
    params[:token]
  end

  def contact_preferences
    params.require(:contact).permit(:token, :mailing_list_consent)
  end

  def mailing_list_consent
    contact_preferences[:mailing_list_consent]
  end
end
