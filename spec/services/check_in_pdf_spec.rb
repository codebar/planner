# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckInPdf do
  subject(:pdf) { described_class.new(event) }

  let(:event) { Fabricate(:event) }

  it 'generates a PDF' do
    output = pdf.render
    expect(output).to start_with('%PDF')
  end

  it 'renders without error' do
    expect { pdf.render }.not_to raise_error
  end
end
