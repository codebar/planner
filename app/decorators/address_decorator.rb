class AddressDecorator < Draper::Decorator
  delegate_all

  def to_html
    [ flat, street, "London, #{postal_code}" ].join("<br/>").html_safe
  end

end
