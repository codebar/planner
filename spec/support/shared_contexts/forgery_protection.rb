# frozen_string_literal: true

RSpec.shared_context 'with forgery protection enforced' do
  before { ActionController::Base.allow_forgery_protection = true }
  after  { ActionController::Base.allow_forgery_protection = false }
end
