class SponsorPresenter < BasePresenter
  include Rails.application.routes.url_helpers

  def contact_info
    [member_contact_details, contact_full_name, model.email].flatten.compact.delete_if(&:empty?).join('<br/>').html_safe
  end

  def member_contact_details
    model.contacts.map do |member|
      h.link_to(member.full_name, admin_member_path(member.id))
    end
  end

  def contact_full_name
    return unless model.contact_first_name && model.contact_surname

    "#{model.contact_first_name.camelize} #{model.contact_surname.camelize}"
  end

  private

  def h
    ActionController::Base.helpers
  end
end
