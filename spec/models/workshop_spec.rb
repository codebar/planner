RSpec.describe Workshop do
  subject(:workshop) { Fabricate(:workshop) }
  include_examples "Invitable", :workshop_invitation, :workshop
  include_examples DateTimeConcerns, :workshop

  context 'validates' do
    it { is_expected.to validate_presence_of(:chapter_id) }

    context "#date_and_time" do
      it 'does not validate if chapter_id blank' do
        workshop.chapter_id = nil
        workshop.date_and_time = nil
        workshop.valid?
        expect(workshop.errors[:date_and_time]).to be_empty
      end

      it 'validate if chapter_id present' do
        workshop.chapter = Fabricate(:chapter)
        workshop.date_and_time = nil
        workshop.valid?
        expect(workshop.errors[:date_and_time]).to include("can't be blank")
      end
    end

    context '#end_at' do
      it 'does not validate if chapter_id blank' do
        workshop.chapter_id = nil
        workshop.ends_at = nil
        workshop.valid?
        expect(workshop.errors[:ends_at]).to be_empty
      end

      it 'validate if chapter_id present' do
        workshop.chapter = Fabricate(:chapter)
        workshop.ends_at = nil
        workshop.valid?
        expect(workshop.errors[:ends_at]).to include("can't be blank")
      end
    end

    context 'if virtual' do
      before { allow(subject).to receive(:virtual?).and_return(true) }
      it { is_expected.to validate_presence_of(:slack_channel) }
      it { is_expected.to validate_presence_of(:slack_channel_link) }
      it { is_expected.to validate_numericality_of(:student_spaces).is_greater_than(0) }
      it { is_expected.to validate_numericality_of(:coach_spaces).is_greater_than(0) }
    end
  end

  context 'time zone fields' do
    let(:workshop) { Fabricate.build(:workshop, chapter: Fabricate(:chapter, time_zone: 'Pacific Time (US & Canada)')) }
    let(:pacific_time) { ActiveSupport::TimeZone['Pacific Time (US & Canada)'].local(2015, 6, 12, 18, 30) }
    let(:utc_time) { pacific_time.in_time_zone('UTC') }

    context 'date_and_time' do
      it 'saves the local time in UTC' do
        workshop.update!(
          local_date: '12/06/2015',
          local_time: '18:30'
        )

        expect(workshop.read_attribute(:date_and_time)).to eq(utc_time)
      end

      it 'retrieves the local time from the saved UTC value' do
        workshop.update_attribute(:date_and_time, utc_time)

        expect(workshop.date_and_time).to eq(pacific_time)
        expect(workshop.date_and_time.zone).to eq('PDT')
      end
    end

    context 'rsvp_opens_at' do
      it 'saves the local time in UTC' do
        workshop.update!(
          rsvp_open_local_date: '12/06/2015',
          rsvp_open_local_time: '18:30'
        )

        expect(workshop.read_attribute(:rsvp_opens_at)).to eq(utc_time)
      end

      it 'retrieves the local time from the saved UTC value' do
        workshop.update_attribute(:rsvp_opens_at, utc_time)

        expect(workshop.rsvp_opens_at).to eq(pacific_time)
        expect(workshop.rsvp_opens_at.zone).to eq('PDT')
      end
    end
  end

  context '#rsvp_available?' do
    context 'rsvp is available' do
      it 'when the event is in the future' do
        workshop.date_and_time = 1.day.from_now

        expect(workshop.rsvp_available?).to be(true)
      end

      it 'when rsvp_closes_at is in the future' do
        workshop.rsvp_closes_at = 2.hours.from_now

        expect(workshop.rsvp_available?).to be(true)
      end

      it 'when rsvp_closes_at is in another timezone' do
        workshop.rsvp_closes_at = 2.hours.from_now.in_time_zone('Pacific Time (US & Canada)')

        expect(workshop.rsvp_available?).to be(true)
      end
    end

    context 'rsvp is not available' do
      it 'when rsvp_closes_at is in the past' do
        workshop.rsvp_closes_at = 2.hours.ago

        expect(workshop.rsvp_available?).to be(false)
      end
    end
  end

  context '#to_s' do
    it 'when physical workshop' do
      expect(workshop.to_s).to eq('Workshop')
    end

    it 'when virtual workshop' do
      workshop = Workshop.new(virtual: true)
      expect(workshop.to_s).to eq('Virtual Workshop')
    end
  end

  context '#scopes' do
    describe '#host' do
      it 'includes workshops with sponsored hosts' do
        workshop_sponsor = Fabricate(:workshop_sponsor, host: true)
        workshop = workshop_sponsor.workshop
        expect(workshop.host).to eq workshop_sponsor.sponsor
      end

      it 'excludes workshops without hosts' do
        workshop_sponsor = Fabricate(:workshop_sponsor, host: false)
        workshop = workshop_sponsor.workshop
        expect(workshop.host).to be_nil
      end

      it 'excludes workshops without sponsor' do
        workshop = Fabricate(:workshop_no_sponsor)
        expect(workshop.host).to be_nil
      end
    end

    context 'attendances' do
      it '#attendee? for students' do
        attendee_invites = 4.times.collect { Fabricate(:workshop_invitation, workshop: workshop, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:workshop_invitation, workshop: workshop, attending: false) }

        attendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be true }
        nonattendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be false }
      end

      it '#attendee? for coaches' do
        attendee_invites = 4.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop, attending: false) }

        attendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be true }
        nonattendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be false }
      end
    end

    context 'Waitlist attendance' do
      it '#waitlisted? for students' do
        invitations = 5.times.collect { Fabricate(:workshop_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:workshop_invitation, workshop: workshop, attending: true) }

        invitations.each { |a| expect(workshop.waitlisted?(a.member)).to be true }
        attendee_invites.each { |a| expect(workshop.waitlisted?(a.member)).to be false }
      end

      it '#waitlisted? for coaches' do
        invitations = 5.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop, attending: true) }

        invitations.each { |a| expect(workshop.waitlisted?(a.member)).to be true }
        attendee_invites.each { |a| expect(workshop.waitlisted?(a.member)).to be false }
      end
    end
  end

  context '#invitable_yet?' do
    it 'is invitable if invitable set to true, no RSVP open time/date set' do
      workshop = Fabricate.build(:workshop, invitable: true)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is invitable if RSVP open date/time in past, and invitable set to false' do
      workshop = Fabricate.build(:workshop, invitable: false, rsvp_opens_at: Time.zone.now - 1.day)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is invitable if RSVP open date/time in future, and invitable set to true' do
      workshop = Fabricate.build(:workshop, invitable: true, rsvp_opens_at: Time.zone.now - 1.day)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is NOT invitable if RSVP open date/time in future, and invitable set to false' do
      workshop = Fabricate.build(:workshop, invitable: false, rsvp_opens_at: Time.zone.now + 1.day)
      expect(workshop.invitable_yet?).to be false
    end
  end
end
