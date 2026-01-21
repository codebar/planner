RSpec.describe AddressPresenter do
  let(:address) { Fabricate.build(:address) }
  let(:presenter) { AddressPresenter.new(address) }

  describe '#to_html' do
    it 'returns the address in HTML with lines separated with <br/> tags' do
      html_address = "#{address.flat}<br/>#{address.street}<br/>#{address.city}, #{address.postal_code}"

      expect(presenter.to_html).to eq(html_address)
    end

    it 'escapes HTML in address elements' do
      address.street = '<script>alert("XSS");</script>'
      html_address = "#{address.flat}<br/>&lt;script&gt;alert(&quot;XSS&quot;);&lt;/script&gt;<br/>" +
        "#{address.city}, #{address.postal_code}"

      expect(presenter.to_html).to eq(html_address)
    end
  end

  it '#to_s' do
    address_to_s = "#{address.flat}, #{address.street}, #{address.city}, #{address.postal_code}"

    expect(presenter.to_s).to eq(address_to_s)
  end
end
