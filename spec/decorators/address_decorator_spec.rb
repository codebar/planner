require 'spec_helper'

describe AddressDecorator do
  let(:address) { Fabricate.build(:address).decorate }

  it "#to_html" do
    html_address = "#{address.flat}<br/>#{address.street}<br/>#{address.city}, #{address.postal_code}"

    address.to_html.should eq(html_address)
  end
end
