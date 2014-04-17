class AddressDecorator < Draper::Decorator
  delegate_all

  def to_html
    [ flat, street, "London, #{postal_code}" ].compact.join("<br/>").html_safe
  end

  def for_map
    [ flat, street, 'London', postal_code ].compact.join(",+")
  end

end
