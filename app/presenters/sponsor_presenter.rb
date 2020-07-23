class SponsorPresenter < BasePresenter
  include Rails.application.routes.url_helpers

  def contact_info
    [member_contacts_details, contacts_details].flatten.compact.join.html_safe
  end

  def member_contacts_details
    model.members.map do |member|
      h.content_tag(:li, h.link_to(member.full_name, admin_member_path(member.id)))
    end
  end

  def contacts_details
    return unless model.contacts.any?

    contacts.map do |c|
      h.content_tag(:li, "#{c.name} #{c.surname} (#{h.mail_to(c.email)})".html_safe)
    end
  end

  private

  def h
    ActionController::Base.helpers
  end
end
