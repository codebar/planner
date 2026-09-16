# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Malformed MIME headers' do
  it 'responds with 406 when the Accept header contains path-traversal junk' do
    get '/', headers: { 'Accept' => '../../../../../../../../../../etc/services{{' }

    expect(response).to have_http_status(:not_acceptable)
  end

  it 'responds with 406 when the Content-Type header contains path-traversal junk' do
    get '/', headers: { 'Content-Type' => '../../../../../../../../../../etc/services{{' }

    expect(response).to have_http_status(:not_acceptable)
  end
end
