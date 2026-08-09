# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CheckInsController do
  let(:admin) { Fabricate(:member) }
  let(:event) { Fabricate(:event) }
  let(:workshop) { Fabricate(:workshop) }

  before { login_as_admin(admin) }

  describe 'GET show' do
    it 'renders the instructions page for an event' do
      get :show, params: { event_id: event.slug }
      expect(response).to be_successful
    end

    it 'renders the instructions page for a workshop' do
      get :show, params: { workshop_id: workshop.id }
      expect(response).to be_successful
    end

    it 'generates a check-in code when missing' do
      event.update_column(:check_in_code, nil)
      expect(event.reload.check_in_code).to be_blank
      get :show, params: { event_id: event.slug }
      expect(event.reload.check_in_code).to be_present
      expect(response).to be_successful
    end

    it 'returns PDF for .pdf format for an event' do
      get :show, params: { event_id: event.slug, format: :pdf }
      expect(response.content_type).to eq('application/pdf')
      expect(response.body).to start_with('%PDF')
    end

    it 'returns PDF for .pdf format for a workshop' do
      get :show, params: { workshop_id: workshop.id, format: :pdf }
      expect(response.content_type).to eq('application/pdf')
      expect(response.body).to start_with('%PDF')
    end
  end
end
