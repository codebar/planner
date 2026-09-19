# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Stats::Range, type: :service do
  subject(:resolve) do
    described_class.resolve(preset:, start_month:, end_month:)
  end

  # AE1/AE2 anchor date: 10 Sep 2026. September is the current partial month.
  around do |example|
    travel_to(Time.zone.local(2026, 9, 10, 12, 0, 0)) { example.run }
  end

  def month_list(dates)
    dates.map { |d| d.strftime('%Y-%m') }
  end

  describe 'presets' do
    it 'resolves the 3-month preset as the last 3 complete months (AE1)' do
      result = described_class.resolve(preset: '3')

      expect(result.status).to eq(:default)
      expect(month_list(result.months)).to eq(%w[2026-06 2026-07 2026-08])
      expect(result.months).to all(be_a(Date))
    end

    it 'excludes the current partial month (AE1)' do
      result = described_class.resolve(preset: '3')

      expect(month_list(result.months)).not_to include('2026-09')
    end

    it 'resolves the 6-month preset ending at the last complete month' do
      result = described_class.resolve(preset: '6')

      expect(month_list(result.months)).to eq(%w[2026-03 2026-04 2026-05 2026-06 2026-07 2026-08])
    end
  end

  describe 'default range (AE2)' do
    it 'resolves the most recent 3 complete months when nothing is supplied' do
      result = described_class.resolve

      expect(result.status).to eq(:default)
      expect(month_list(result.months)).to eq(%w[2026-06 2026-07 2026-08])
    end

    it 'falls back to the default range on malformed month values' do
      result = described_class.resolve(start_month: 'not-a-month', end_month: '2026-08')

      expect(result.status).to eq(:default)
      expect(result.months.length).to eq(3)
      expect(month_list(result.months).last).to eq('2026-08')
    end

    it 'falls back to the default range when only one custom month is supplied' do
      result = described_class.resolve(start_month: '2026-01')

      expect(result.status).to eq(:default)
      expect(result.months.length).to eq(3)
    end

    it 'falls back to the default range on an unrecognised preset' do
      result = described_class.resolve(preset: '7')

      expect(result.status).to eq(:default)
      expect(result.months.length).to eq(3)
    end
  end

  describe 'custom ranges' do
    it 'resolves an inclusive start/end range' do
      result = described_class.resolve(start_month: '2026-01', end_month: '2026-03')

      expect(result.status).to eq(:custom)
      expect(month_list(result.months)).to eq(%w[2026-01 2026-02 2026-03])
    end

    it 'yields a single month when start equals end' do
      result = described_class.resolve(start_month: '2026-05', end_month: '2026-05')

      expect(result.status).to eq(:custom)
      expect(month_list(result.months)).to eq(%w[2026-05])
    end

    it 'clamps an end month in the current month to the last complete month' do
      result = described_class.resolve(start_month: '2026-06', end_month: '2026-09')

      expect(result.status).to eq(:custom)
      expect(month_list(result.months)).to eq(%w[2026-06 2026-07 2026-08])
    end

    it 'clamps an end month in the future to the last complete month' do
      result = described_class.resolve(start_month: '2026-01', end_month: '2027-04')

      expect(result.status).to eq(:custom)
      expect(month_list(result.months).last).to eq('2026-08')
    end

    it 'spans a year boundary correctly' do
      result = described_class.resolve(start_month: '2025-11', end_month: '2026-02')

      expect(month_list(result.months)).to eq(%w[2025-11 2025-12 2026-01 2026-02])
    end

    it 'spans a past leap-year February correctly' do
      result = described_class.resolve(start_month: '2024-01', end_month: '2024-03')

      expect(month_list(result.months)).to eq(%w[2024-01 2024-02 2024-03])
      expect(result.months[1]).to eq(Date.new(2024, 2, 1))
    end

    it 'rejects a start month after the end month' do
      result = described_class.resolve(start_month: '2026-08', end_month: '2026-01')

      expect(result.status).to eq(:invalid)
    end

    it 'rejects a start month that lands after the clamp (start in a future month)' do
      result = described_class.resolve(start_month: '2026-12', end_month: '2027-02')

      expect(result.status).to eq(:invalid)
    end

    it 'rejects a start month in the current partial month after the end clamps back' do
      result = described_class.resolve(start_month: '2026-09', end_month: '2026-10')

      expect(result.status).to eq(:invalid)
    end

    it 'gives explicit start/end months precedence over a preset when both arrive' do
      result = described_class.resolve(preset: '3', start_month: '2026-01', end_month: '2026-02')

      expect(result.status).to eq(:custom)
      expect(month_list(result.months)).to eq(%w[2026-01 2026-02])
    end
  end

  describe 'result shape' do
    it 'exposes month dates anchored at the first of the month' do
      result = described_class.resolve(preset: '3')

      expect(result.months).to eq([Date.new(2026, 6, 1), Date.new(2026, 7, 1), Date.new(2026, 8, 1)])
    end

    it 'carries the parsed custom months for error display' do
      result = described_class.resolve(start_month: '2026-08', end_month: '2026-06')

      expect(result.status).to eq(:invalid)
      expect(result.start_month).to eq(Date.new(2026, 8, 1))
      expect(result.end_month).to eq(Date.new(2026, 6, 1))
    end

    it 'routes spans beyond the maximum to the invalid state' do
      result = described_class.resolve(start_month: '2000-01', end_month: '2026-08')

      expect(result.status).to eq(:invalid)
      expect(result.months).to be_empty
    end

    it 'keeps a 20-year custom range valid' do
      result = described_class.resolve(start_month: '2006-09', end_month: '2026-08')

      expect(result.status).to eq(:custom)
      expect(result.months.size).to eq(240)
    end

    it 'exposes nil parsed custom months on the default range' do
      result = described_class.resolve

      expect(result.start_month).to be_nil
      expect(result.end_month).to be_nil
    end
  end
end
