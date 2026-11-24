require 'rails_helper'

RSpec.describe TermsAndConditionsForm do
  def form_with(terms)
    described_class.new(terms:)
  end

  it 'accepts "1", the value a marked checkbox posts' do
    expect(form_with('1')).to be_valid
  end

  it 'accepts true' do
    expect(form_with(true)).to be_valid
  end

  it 'rejects "0", the value an unmarked checkbox posts' do
    expect(form_with('0')).to be_invalid
  end

  it 'rejects an empty value' do
    expect(form_with('')).to be_invalid
  end

  it 'rejects false' do
    expect(form_with(false)).to be_invalid
  end

  it 'rejects a missing value' do
    form = form_with(nil)

    expect(form).to be_invalid
    expect(form.errors[:terms]).to be_present
  end
end
