# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckInPdf do
  let(:event) { Fabricate(:event) }

  subject { described_class.new(event) }

  it "generates a PDF" do
    pdf = subject.render
    expect(pdf).to start_with("%PDF")
  end

  it "renders without error" do
    expect { subject.render }.not_to raise_error
  end
end
