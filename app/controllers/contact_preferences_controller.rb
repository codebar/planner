class ContactPreferencesController < ApplicationController
  def show
    @contact = Contact.find_by(token: token)

    return if @contact

    flash[:notice] = I18n.t('messages.invalid_session')
  end

  def update
    contact = Contact.find_by(token: contact_preferences[:token])
    contact.update(mailing_list_consent: mailing_list_consent)
    audit_contact_subscription(contact)

    redirect_to contact_preferences_path(token: contact_preferences[:token],
                                         notice: I18n.t('messages.contact_preferences.updated'))
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

  def subscription_preference(contact)
    contact.mailing_list_consent ? 'sponsor.contact_subscribe' : 'sponsor.contact_unsubscribe'
  end

  def audit_contact_subscription(contact)
    Auditor::Audit.new(contact.sponsor, subscription_preference(contact), contact)
                  .log_with_note(contact.email)
  end
end
