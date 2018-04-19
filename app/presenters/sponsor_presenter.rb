class SponsorPresenter < SimpleDelegator
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
    if model.contact_first_name && model.contact_surname
      "#{model.contact_first_name.capitalize} #{model.contact_surname.capitalize}"
    end
  end

  private

  def model
    __getobj__
  end

  def h
    ActionController::Base.helpers
  end
end
