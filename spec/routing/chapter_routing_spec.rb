# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'chapter catch-all route' do
  it 'routes a chapter slug to chapter#show' do
    expect(get: '/london').to route_to(controller: 'chapter', action: 'show', id: 'london')
  end

  # Chapter#set_slug builds slugs with name.parameterize, which produces
  # lowercase letters, digits, hyphens, and underscores.
  it 'routes every character class the slug generator can produce' do
    expect(get: '/123').to route_to(controller: 'chapter', action: 'show', id: '123')
    expect(get: '/south-london').to route_to(controller: 'chapter', action: 'show', id: 'south-london')
    expect(get: '/spring_wildcats').to route_to(controller: 'chapter', action: 'show', id: 'spring_wildcats')
  end

  it 'does not route paths containing dots' do
    expect(get: '/key.pem').not_to be_routable
  end

  it 'does not route paths containing uppercase characters' do
    expect(get: '/Shanghai').not_to be_routable
  end
end
