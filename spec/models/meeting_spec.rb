RSpec.describe Meeting do
  include_examples 'Invitable', :meeting_invitation, :meeting
  include_examples DateTimeConcerns, :meeting

  context 'validations' do
    subject(:meeting) { Fabricate(:meeting) }

    it { is_expected.to validate_presence_of(:date_and_time) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to belong_to(:venue) }

    describe '#slug' do
      it 'fails when slug not present' do
        Fabricate(:meeting, slug: 'meeting')
        new_meeting = Fabricate.build(:meeting, slug: 'meeting')
        new_meeting.slug = ''
        new_meeting.valid?

        expect(new_meeting.errors[:slug]).to be_empty
      end

      it 'passes if slug present' do
        Fabricate(:meeting, slug: 'meeting')
        new_meeting = Fabricate.build(:meeting, slug: 'meeting')
        new_meeting.date_and_time = nil
        new_meeting.slug = 'meeting'

        new_meeting.valid?

        expect(new_meeting.errors[:slug]).to include('has already been taken')
      end
    end
  end

  describe '#title' do
    subject(:meeting) { described_class.new(date_and_time: Time.zone.local(2014, 8, 20, 18, 30)) }

    it 'is formatted correctly' do
      expect(meeting.title).to eq('August Meeting')
    end
  end

  describe '#set_slug' do
    it 'loops until it finds an available slug' do
      Fabricate.times(4, :meeting, name: 'monthly')
      meeting = Fabricate(:meeting, name: 'monthly')
      expect(meeting.slug)
        .to eq("#{I18n.l(meeting.date_and_time, format: :year_month).downcase}-monthly-5")
    end
  end

  describe '#not_full' do
    it 'returns true if meeting is not full' do
      meeting = Fabricate(:meeting)
      Fabricate(:attending_meeting_invitation, meeting: meeting)

      expect(meeting.not_full).to be(true)
    end

    it 'returns false if meeting is full' do
      meeting = Fabricate(:meeting)
      Fabricate.times(21, :attending_meeting_invitation, meeting: meeting)

      expect(meeting.not_full).to be(false)
    end
  end

  describe '#attendees_csv' do
    it 'generates a csv of attendees' do
      meeting = Fabricate(:meeting)
      invitations = Fabricate.times(2, :attending_meeting_invitation, meeting: meeting)

      expect(meeting.attendees_csv).not_to be_blank
      invitations.each do |invitation|
        expect(meeting.attendees_csv).to include(invitation.member.full_name)
      end
    end
  end
end
