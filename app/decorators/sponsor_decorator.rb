class SponsorDecorator < Draper::Decorator
  delegate_all

  def contact_info
    [member_contact_details, contact_full_name, email].flatten.compact.delete_if(&:empty?).join('<br/>').html_safe
  end

  def member_contact_details
    contacts.map do |member| 
      h.link_to(member.full_name, h.admin_member_path(member.id))
    end
  end

  def contact_full_name
    if contact_first_name && contact_surname
      "#{contact_first_name.capitalize} #{contact_surname.capitalize}"
    end
  end
end
