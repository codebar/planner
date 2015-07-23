class AddressDecorator < Draper::Decorator
  delegate_all

  def to_html
    [ flat, street, "#{city}, #{postal_code}" ].compact.delete_if(&:empty?).join("<br/>").html_safe
  end

  def for_map
    [ flat, street, city, postal_code ].delete_if(&:empty?).join(",+")
  end

  def to_s
    [ flat, street, city, postal_code ].delete_if(&:empty?).join(", ")
  end
end
