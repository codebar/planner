RSpec.describe AdminWorkshopAttendeeFlags do
  subject(:flags) { described_class.for_members([member.id])[member.id] }

  let(:workshop) { Fabricate(:workshop) }
  let(:member) { Fabricate(:member) }

  def count_queries(&block)
    n = 0
    callback = ->(*) { n += 1 }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &block)
    n
  end

  describe '.for_members' do
    context 'when determining if a member is a newbie' do
      it 'is true when the member has never attended a workshop' do
        Fabricate(:attending_workshop_invitation, member:, workshop:)

        expect(flags[:newbie]).to be(true)
      end

      it 'is false when the member has attended a workshop in the past' do
        Fabricate(:attended_workshop_invitation, member:)

        expect(flags[:newbie]).to be(false)
      end
    end

    context 'when determining the flag to organisers' do
      it 'is true when the member has multiple no-shows and two recent warnings' do
        4.times { Fabricate(:past_attending_workshop_invitation, member:) }
        2.times { Fabricate(:attendance_warning, member:) }

        expect(flags[:flag_to_organisers]).to be(true)
      end

      it 'is false when the member has few no-shows' do
        Fabricate(:past_attending_workshop_invitation, member:)
        2.times { Fabricate(:attendance_warning, member:) }

        expect(flags[:flag_to_organisers]).to be(false)
      end

      it 'is false when the member has no recent warnings' do
        4.times { Fabricate(:past_attending_workshop_invitation, member:) }

        expect(flags[:flag_to_organisers]).to be(false)
      end
    end

    context 'when determining recent notes' do
      it 'is true when a note exists after the member\'s fifth most recent attended workshop' do
        5.times { Fabricate(:attended_workshop_invitation, member:) }

        Fabricate(:member_note, member:, created_at: 1.day.ago)

        expect(flags[:recent_notes]).to be(true)
      end

      it 'is false when there are no notes' do
        5.times { Fabricate(:attended_workshop_invitation, member:) }

        expect(flags[:recent_notes]).to be(false)
      end
    end

    it 'runs a constant number of queries regardless of member count' do
      members = Array.new(5) { Fabricate(:member) }
      members.each do |current_member|
        4.times { Fabricate(:past_attending_workshop_invitation, member: current_member) }
        2.times { Fabricate(:attendance_warning, member: current_member) }
        Fabricate(:member_note, member: current_member, created_at: 1.day.ago)
      end

      one = count_queries { described_class.for_members(members.take(1).map(&:id)) }
      many = count_queries { described_class.for_members(members.map(&:id)) }

      expect(many).to be <= one + 2
    end
  end
end
