require 'rails_helper'

RSpec.describe Admin::StatsController do
  let(:admin) { Fabricate(:member) }

  around { |example| travel_to(Time.zone.local(2026, 9, 10, 12, 0, 0)) { example.run } }

  describe 'GET #index as HTML' do
    before { login_as_admin(admin) }

    it 'renders the default most recent 3 complete months (AE2)' do
      get :index

      expect(response).to be_successful
      months = controller.view_assigns['months']
      expect(months).to eq([Date.new(2026, 6, 1), Date.new(2026, 7, 1), Date.new(2026, 8, 1)])
    end

    it 'renders the 3-month preset anchored at the last complete month (AE1)' do
      get :index, params: { stats: { preset: '3' } }

      expect(controller.view_assigns['months'])
        .to eq([Date.new(2026, 6, 1), Date.new(2026, 7, 1), Date.new(2026, 8, 1)])
    end

    it 'prefers explicit start/end months over a preset when both are supplied (KTD4)' do
      get :index, params: { stats: { preset: '3', start_month: '2026-01', end_month: '2026-02' } }

      expect(controller.view_assigns['months'])
        .to eq([Date.new(2026, 1, 1), Date.new(2026, 2, 1)])
    end

    it 'keeps the previous valid range and shows an inline error for a start-after-end range (R7)' do
      get :index, params: { stats: { preset: '3' } }
      previous = controller.view_assigns['months']

      get :index, params: { stats: { start_month: '2026-08', end_month: '2026-03' } }

      expect(controller.view_assigns['months']).to eq(previous)
      expect(controller.view_assigns['range_result']).not_to be_invalid
      expect(controller.view_assigns['range_error']).to be_present
    end

    it 'renders the default range with an inline error when the first request is invalid' do
      get :index, params: { stats: { start_month: '2026-08', end_month: '2026-03' } }

      expect(controller.view_assigns['months'].size).to eq(3)
      expect(controller.view_assigns['range_error']).to be_present
    end

    it 'filters unpermitted keys and does not leak them to the service' do
      get :index, params: { stats: { preset: '3', hacker_field: 'malicious' }, evil: 'pwn' }

      expect(response).to be_successful
      expect(controller.view_assigns['months'].size).to eq(3)
    end

    it 'raises for a type-tampered stats parameter (params.expect contract)' do
      expect { get :index, params: { stats: 'evil' } }
        .to raise_error(ActionController::ParameterMissing)
    end

    it 'exposes range inputs for the view' do
      get :index, params: { stats: { start_month: '2026-01', end_month: '2026-03' } }

      expect(controller.view_assigns['range_start']).to eq('2026-01')
      expect(controller.view_assigns['range_end']).to eq('2026-03')
    end
  end

  describe 'GET #index as CSV' do
    let!(:workshop) do
      Fabricate(:workshop, date_and_time: Time.zone.local(2026, 1, 15, 18, 30))
    end

    before do
      login_as_admin(admin)
      Fabricate(:attending_workshop_invitation, workshop:, role: 'Student')
      Fabricate(:attended_workshop_invitation, workshop:, role: 'Coach')
      Fabricate(:member, created_at: Time.zone.local(2026, 1, 5, 10, 0, 0)).tap do |member|
        member.groups << Fabricate(:students)
      end
      Fabricate(:member, created_at: Time.zone.local(2026, 2, 9, 10, 0, 0)).tap do |member|
        member.groups << Fabricate(:coaches)
      end
      Fabricate(:member, created_at: Time.zone.local(2026, 3, 1, 10, 0, 0))
    end

    it 'returns a text/csv attachment mirroring the HTML table (AE5)' do
      filters = { stats: { start_month: '2026-01', end_month: '2026-03' } }

      get :index, params: filters
      months = controller.view_assigns['months']
      expected_rows = controller.view_assigns['rows']

      get :index, params: filters, format: :csv

      expect(response.media_type).to eq('text/csv')
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.headers['Content-Disposition'])
        .to include('codebar-stats-2026-01-2026-03.csv')

      parsed = CSV.parse(response.body)
      expect(parsed.first).to eq(%w[Metric 2026-01 2026-02 2026-03 Totals])
      expect(parsed.size).to eq(expected_rows.size + 1)

      expected_rows.each_with_index do |row, index|
        expect(parsed[index + 1])
          .to eq([row.label, *months.map { |m| row.cells[m].to_s }, row.total.to_s])
      end
    end

    it 'counts fabricated data through the real service chain' do
      get :index, params: { stats: { start_month: '2026-01', end_month: '2026-01' } }

      rows = controller.view_assigns['rows'].index_by(&:label)
      expect(rows['Student check-ins'].cells[Date.new(2026, 1, 1)]).to eq(0)
      expect(rows['Coach check-ins'].cells[Date.new(2026, 1, 1)]).to eq(1)
      expect(rows['Student RSVPs'].cells[Date.new(2026, 1, 1)]).to eq(1)
      expect(rows['New students'].cells[Date.new(2026, 1, 1)]).to eq(1)
      expect(rows['Total new members'].cells[Date.new(2026, 1, 1)]).to eq(1)
      expect(rows['Workshops'].cells[Date.new(2026, 1, 1)]).to eq(1)
    end

    it 'falls back to the default 3 months when the supplied range is invalid (R9)' do
      get :index, params: { stats: { start_month: '2026-08', end_month: '2026-03' } }, format: :csv

      expect(response).to be_successful
      header = CSV.parse(response.body).first
      expect(header[1]).to eq('2026-06')
      expect(header[-2]).to eq('2026-08')
      expect(header.last).to eq('Totals')
    end

    it 'clamps a CSV end month in the current month to the last complete month (R9 parity with R7)' do
      get :index, params: { stats: { start_month: '2026-06', end_month: '2026-09' } }, format: :csv

      expect(response).to be_successful
      header = CSV.parse(response.body).first
      expect(header[1]).to eq('2026-06')
      expect(header[-2]).to eq('2026-08')
    end

    it 'falls back to the default 3 months for malformed months (R9)' do
      get :index, params: { stats: { start_month: 'garbage', end_month: 'also-bad' } },
                  format: :csv

      expect(response).to be_successful
      expect(CSV.parse(response.body).first.size).to eq(5)
    end
  end

  describe 'denial paths (AE7)' do
    let(:chapter) { Fabricate(:chapter) }
    let(:organiser) { Fabricate(:member) }

    before { login_as_organiser(organiser, chapter) }

    it 'redirects an organiser from the page to the root' do
      get :index

      expect(response).to redirect_to(root_path)
    end

    it 'redirects an organiser from the CSV export to the root' do
      get :index, format: :csv

      expect(response).to redirect_to(root_path)
    end

    it 'redirects a signed-out visitor from either format' do
      LoginHelpers::LoginStub.current_user = nil

      get :index
      expect(response).to redirect_to(root_path)

      get :index, format: :csv
      expect(response).to redirect_to(root_path)
    end
  end
end
