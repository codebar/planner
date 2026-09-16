# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rollbar configuration' do # rubocop:disable RSpec/DescribeClass
  describe 'exception level filters' do
    it 'ignores InvalidType exceptions raised for malformed MIME headers' do
      filter = Rollbar.configuration.exception_level_filters['ActionDispatch::Http::MimeNegotiation::InvalidType']

      expect(filter).to eq('ignore')
    end
  end
end
