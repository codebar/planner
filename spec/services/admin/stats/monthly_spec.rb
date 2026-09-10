# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Stats::Monthly do
  subject(:result) { described_class.call(range) }

  let(:range) do
    Admin::Stats::Range.resolve(start_month: '2026-05', end_month: '2026-07')
  end

  def row(section, label)
    result.rows.find { |r| r.section == section && r.label == label }
  end

  def cell(section, label, month)
    row(section, label).cells[Date.new(*month)]
  end

  def total_for(section, label)
    row(section, label).total
  end

  describe 'attendance rows (R3)' do
    it 'Covers AE4. counts student RSVPs and check-ins against the workshop month' do
      workshop = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 5, 15, 18, 30))
      10.times do |i|
        invitation = Fabricate(:attending_workshop_invitation, workshop:, role: 'Student')
        invitation.update!(attended: true) if i < 7
      end

      expect(cell(:attendance, 'Student RSVPs', [2026, 5])).to eq(10)
      expect(cell(:attendance, 'Student check-ins', [2026, 5])).to eq(7)
    end

    it 'counts coach attendance on the coach rows' do
      workshop = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 3, 18, 30))
      Fabricate(:attending_workshop_invitation, workshop:, role: 'Coach', attended: true)

      expect(cell(:attendance, 'Coach check-ins', [2026, 6])).to eq(1)
      expect(cell(:attendance, 'Coach RSVPs', [2026, 6])).to eq(1)
      expect(cell(:attendance, 'Student check-ins', [2026, 6])).to eq(0)
    end

    it 'excludes a workshop dated outside the range from every column' do
      outside = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 4, 20, 18, 30))
      Fabricate(:attending_workshop_invitation, workshop: outside, role: 'Student', attended: true)
      Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 8, 1, 18, 30))

      expect(total_for(:attendance, 'Student RSVPs')).to eq(0)
      expect(total_for(:workshops, 'Workshops')).to eq(0)
    end

    it 'excludes waiting-listed invitations (attending nil) from the RSVP rows' do
      workshop = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 10, 18, 30))
      Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: nil)

      expect(cell(:attendance, 'Student RSVPs', [2026, 6])).to eq(0)
      expect(cell(:attendance, 'Student check-ins', [2026, 6])).to eq(0)
    end

    it 'excludes invitations with a nil role from both attendance rows' do
      workshop = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 10, 18, 30))
      Fabricate(:attending_workshop_invitation, workshop:, role: nil, attended: true)

      expect(cell(:attendance, 'Student RSVPs', [2026, 6])).to eq(0)
      expect(cell(:attendance, 'Coach check-ins', [2026, 6])).to eq(0)
    end

    it 'counts attendances, not distinct members' do
      member = Fabricate(:member)
      may = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 5, 6, 18, 30))
      june = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 10, 18, 30))
      Fabricate(:attended_workshop_invitation, workshop: may, member:, role: 'Student')
      Fabricate(:attended_workshop_invitation, workshop: june, member:, role: 'Student')

      expect(cell(:attendance, 'Student check-ins', [2026, 5])).to eq(1)
      expect(cell(:attendance, 'Student check-ins', [2026, 6])).to eq(1)
      expect(total_for(:attendance, 'Student check-ins')).to eq(2)
    end

    it 'counts virtual workshops toward the workshop row' do
      Fabricate(:virtual_workshop, date_and_time: Time.zone.local(2026, 7, 1, 18, 30))

      expect(cell(:workshops, 'Workshops', [2026, 7])).to eq(1)
    end
  end

  describe 'sign-up rows (R4, D8)' do
    it 'Covers AE3. assigns a members-only-coaches group member to the coaches row' do
      member = Fabricate(:member, created_at: Time.zone.local(2026, 6, 10, 14, 0))
      Fabricate(:subscription, member:, group: Fabricate(:coaches))

      expect(cell(:sign_ups, 'New coaches', [2026, 6])).to eq(1)
      expect(cell(:sign_ups, 'New students', [2026, 6])).to eq(0)
      expect(cell(:sign_ups, 'Uncategorised', [2026, 6])).to eq(0)
      expect(cell(:sign_ups, 'Total new members', [2026, 6])).to eq(1)
    end

    it 'Covers AE6. counts a dual-group member once in the total and in both role rows' do
      member = Fabricate(:member, created_at: Time.zone.local(2026, 7, 5, 9, 0))
      Fabricate(:subscription, member:, group: Fabricate(:students))
      Fabricate(:subscription, member:, group: Fabricate(:coaches))

      expect(cell(:sign_ups, 'New students', [2026, 7])).to eq(1)
      expect(cell(:sign_ups, 'New coaches', [2026, 7])).to eq(1)
      expect(cell(:sign_ups, 'Total new members', [2026, 7])).to eq(1)
    end

    it 'lands a member with no subscriptions in uncategorised and the total' do
      Fabricate(:member, created_at: Time.zone.local(2026, 5, 20, 12, 0))

      expect(cell(:sign_ups, 'Uncategorised', [2026, 5])).to eq(1)
      expect(cell(:sign_ups, 'Total new members', [2026, 5])).to eq(1)
    end

    it 'counts banned members and members without accepted terms (D8: no status filter)' do
      Fabricate(:banned_member, created_at: Time.zone.local(2026, 5, 2, 10, 0))
      Fabricate(:member_without_toc, created_at: Time.zone.local(2026, 5, 3, 10, 0))

      expect(cell(:sign_ups, 'Total new members', [2026, 5])).to eq(2)
    end

    it 'excludes members created outside the range' do
      Fabricate(:member, created_at: Time.zone.local(2026, 4, 10, 10, 0))
      Fabricate(:member, created_at: Time.zone.local(2026, 8, 10, 10, 0))

      expect(total_for(:sign_ups, 'Total new members')).to eq(0)
    end
  end

  describe 'range totals (R8)' do
    it 'sums each row across exactly the range months, never all time' do
      workshop = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 6, 10, 18, 30))
      Fabricate(:attending_workshop_invitation, workshop:, role: 'Student')
      Fabricate(:attending_workshop_invitation, workshop:, role: 'Coach')
      old_workshop = Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2025, 6, 10, 18, 30))
      Fabricate(:attending_workshop_invitation, workshop: old_workshop, role: 'Student')
      Fabricate(:member, created_at: Time.zone.local(2026, 5, 10))

      aggregate_failures do
        result.rows.each do |r|
          expect(r.total).to eq(r.cells.values.sum),
                             "row #{r.label}: total #{r.total} != cell sum #{r.cells.values.sum}"
        end
        expect(total_for(:attendance, 'Student RSVPs')).to eq(1)
        expect(total_for(:workshops, 'Workshops')).to eq(1)
      end
    end
  end

  describe 'range handling' do
    it 'includes zero cells for months with no data' do
      expect(cell(:workshops, 'Workshops', [2026, 5])).to eq(0)
      expect(row(:workshops, 'Workshops').cells.keys).to eq(
        [Date.new(2026, 5, 1), Date.new(2026, 6, 1), Date.new(2026, 7, 1)]
      )
    end

    it 'returns an empty result for an invalid range' do
      invalid = Admin::Stats::Range.resolve(start_month: '2026-07', end_month: '2026-05')

      outcome = described_class.call(invalid)

      expect(outcome.months).to eq([])
      expect(outcome.rows).to eq([])
    end

    it 'aggregates across all chapters (R2, organisation-wide)' do
      Fabricate(:workshop_no_sponsor, date_and_time: Time.zone.local(2026, 5, 5, 18, 30))
      other_chapter = Fabricate(:chapter)
      Fabricate(:workshop_no_sponsor, chapter: other_chapter,
                                      date_and_time: Time.zone.local(2026, 5, 12, 18, 30))

      expect(cell(:workshops, 'Workshops', [2026, 5])).to eq(2)
    end
  end
end
