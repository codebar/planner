# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Stats::TableComponent do
  let(:months) { [Date.new(2026, 6, 1), Date.new(2026, 7, 1), Date.new(2026, 8, 1)] }
  let(:row) do
    Admin::Stats::Monthly::Row.new(section: :attendance, label: 'Student check-ins',
                                   cells: { Date.new(2026, 6, 1) => 1234, Date.new(2026, 7, 1) => 7,
                                            Date.new(2026, 8, 1) => 0 },
                                   total: 1241)
  end

  it 'renders the caption above the table' do
    render_inline(described_class.new(months: [Date.new(2026, 6, 1)], rows: [row], caption: 'Attendance'))

    expect(page).to have_css('caption.caption-top', text: 'Attendance')
  end

  it 'renders the caption, month columns, and the Totals column' do
    render_inline(described_class.new(months: [Date.new(2026, 6, 1)], rows: [row], caption: 'Attendance'))

    expect(page).to have_css('caption', text: 'Attendance')
    expect(page).to have_css('th', text: 'June 2026')
    expect(page).to have_css('th', text: 'Totals')
  end

  it 'right-aligns numeric cells and formats them with thousands separators' do
    render_inline(described_class.new(months: [Date.new(2026, 6, 1)], rows: [row], caption: 'Attendance'))

    expect(page).to have_css('td.text-end', text: '1,234')
    expect(page).to have_css('td.text-end', text: '1,241') # totals cell
  end

  it 'shows each cell as a percentage of the row total in brackets for returning rows' do
    returning_row = Admin::Stats::Monthly::Row.new(section: :attendance, label: 'Returning students',
                                                   cells: { Date.new(2026, 6, 1) => 1234, Date.new(2026, 7, 1) => 7,
                                                            Date.new(2026, 8, 1) => 0 },
                                                   total: 1241)

    render_inline(described_class.new(months:, rows: [returning_row], caption: 'Attendance'))

    expect(page).to have_css('td.text-end', text: '1,234 (99%)')
    expect(page).to have_css('td.text-end', text: '7 (1%)')
    expect(page).to have_css('td.text-end', text: '0 (0%)')
  end

  it 'does not show percentages for other metric rows' do
    render_inline(described_class.new(months:, rows: [row], caption: 'Attendance'))

    expect(page).to have_css('td.text-end', text: '7')
    expect(page).to have_no_css('td.text-end', text: '7 (')
  end

  it 'shows 0% when a returning row has a zero total' do
    zero_row = Admin::Stats::Monthly::Row.new(section: :attendance, label: 'Returning coaches',
                                              cells: { Date.new(2026, 6, 1) => 0 }, total: 0)

    render_inline(described_class.new(months: [Date.new(2026, 6, 1)], rows: [zero_row], caption: 'Attendance'))

    expect(page).to have_css('td.text-end', text: '0 (0%)')
    expect(page).to have_css('td.text-end', text: '0') # totals cell
  end

  it 'renders one table per metric group, with no section banner rows' do
    workshops_row = Admin::Stats::Monthly::Row.new(section: :workshops, label: 'Workshops',
                                                   cells: { Date.new(2026, 6, 1) => 2 }, total: 2)

    render_inline(described_class.new(months: [Date.new(2026, 6, 1)], rows: [row], caption: 'Attendance'))
    attendance_table = page

    render_inline(described_class.new(months: [Date.new(2026, 6, 1)], rows: [workshops_row], caption: 'Workshops'))

    expect(attendance_table).to have_no_css('td[colspan]')
    expect(page).to have_css('caption', text: 'Workshops')
  end

  it 'renders zero for a month missing from the row cells' do
    render_inline(described_class.new(months: [Date.new(2026, 5, 1)], rows: [row], caption: 'Attendance'))

    expect(page).to have_css('td.text-end', text: '0')
  end
end
