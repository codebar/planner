require 'spec_helper'

RSpec.describe WorkshopPresenter do
  let(:chapter) { Fabricate(:chapter) }
  let(:host) { Fabricate(:sponsor, seats: 5, number_of_coaches: 15) }
  let(:workshop) { double(:workshop, host: host, chapter: chapter) }
  let(:presenter) { WorkshopPresenter.new(workshop) }

  def double_workshop(attending_coaches:, attending_students:)
    double(:workshop, host: host, chapter: chapter,
                      attending_coaches: double(:attending_coaches, count: attending_coaches),
                      attending_students: double(:attending_students, count: attending_students))
  end


  context '#decorate' do
    it 'returns a workshop decorated with the WorkshopPresenter' do
      workshop = double(:workshop, virtual?: false)
      presenter = WorkshopPresenter.decorate(workshop)
      expect(presenter).to be_a(WorkshopPresenter)
    end

    it 'returns a virtual workshop decorated with the VirtualWorkshopPresenter' do
      workshop = double(:workshop, virtual?: true)
      presenter = WorkshopPresenter.decorate(workshop)
      expect(presenter).to be_a(VirtualWorkshopPresenter)
    end
  end

  context '#address' do
    it 'returns the decorated address of the workshop\'s venue' do
      expect(presenter.address.to_html).to eq(AddressPresenter.new(host.address).to_html)
    end
  end

  context '#attending_and_available_student_spots' do
  let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 4) }

    it 'returns the attending students count over the available workshop spots' do
      expect(presenter.attending_and_available_student_spots).to eq('4/5')
    end
  end

  context '#attending_and_available_coach_spots' do
  let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 4) }

    it 'returns the attending coaches count over the available workshop spots' do
      expect(presenter.attending_and_available_coach_spots).to eq('3/15')
    end
  end


  context '#title' do
    it 'returns the title of a workshop' do
      expect(presenter.title).to eq("Workshop at #{host.name}")
    end
  end

  it '#venue' do
    expect(workshop).to receive(:host)

    presenter.venue
  end

  it '#organisers' do
    expect(workshop).to receive(:permissions)
    expect(workshop).to receive(:chapter).and_return(chapter)

    presenter.organisers
  end

  context 'time formatting' do
    let(:workshop) { double(:workshop, time: Time.zone.now, ends_at: 1.hour.from_now) }

    it '#time' do
      start_time = workshop.time

      expect(presenter.time).to eq(I18n.l(start_time, format: :time))
    end

    it '#end_time' do
      expect(presenter.end_time).to eq(I18n.l(workshop.ends_at, format: :time))
    end

    context '#start_and_end_time' do
      it 'when no end_time is set it only returns the start_time' do
        workshop =  double(:workshop, time: Time.zone.now, ends_at: nil)
        presenter = WorkshopPresenter.new(workshop)

        expect(presenter.start_and_end_time).to eq(I18n.l(workshop.time, format: :time))
      end

      it 'when a start and an end_time are set it returns a formatted start and end_time' do
        workshop =  double(:workshop, time: Time.zone.now, ends_at: 1.hour.from_now)
        presenter = WorkshopPresenter.new(workshop)

        expect(presenter.start_and_end_time)
          .to eq("#{I18n.l(workshop.time, format: :time)} - #{I18n.l(workshop.ends_at, format: :time)}")
      end
    end

    context '#humanize_date_with_time_range' do
      before { travel_to Time.local(2020, 1, 1, 18, 30) }

      it 'displays range when available' do
        presenter = WorkshopPresenter.new(Fabricate(:workshop, date_and_time: Time.zone.now,
                                                              ends_at: Time.zone.now + 2.hours))

        expect(presenter.humanize_date_with_time_range) .to eq 'Wed, 1st January at 18:30 - 20:30'
      end

      it 'displays start time only if end unavailable' do
        presenter = WorkshopPresenter.new(Fabricate(:workshop, date_and_time: Time.zone.now,
                                                              ends_at: nil))

        expect(presenter.humanize_date_with_time_range) .to eq 'Wed, 1st January at 18:30'
      end

      after { travel_back }
    end
  end

  context '#attendees_csv' do
    let(:invitations) do
      [Fabricate.times(2, :student_workshop_invitation), Fabricate.times(2, :coach_workshop_invitation)].flatten
    end
    let(:workshop) { double(:workshop, attendances: invitations) }

    it 'correctly returns the formatted list of workshop participants' do
      expect(presenter).to receive(:organisers).at_least(:once).and_return [invitations.last.member]
      expect(presenter.attendees_csv).not_to be_blank

      invitations.each do |invitation|
        expect(presenter.attendees_csv).to include(invitation.member.full_name)
        expect(presenter.attendees_csv).to include(invitation.role.upcase).or include('ORGANISER')
      end
      expect(presenter.attendees_csv).to include('ORGANISER')
      expect(presenter.attendees_csv).to include('STUDENT')
      expect(presenter.attendees_csv).to include('COACH')
    end
  end

  context '#pairing_csv' do
    let(:workshop) { double(:workshop, attendances: [invitation]) }
    let(:student) { Fabricate(:student) }
    let(:invitation) { Fabricate(:workshop_invitation, member: student) }

    it 'returns a csv with all the details required to enable organisers to pair the participants' do
      student_pairing_array = [true, student.full_name, 'Student', invitation.note, 'N/A']
      student_presenter = MemberPresenter.new(student)

      expect(presenter.pairing_csv)
        .to eq(WorkshopPresenter::PAIRING_HEADINGS.join(',') + "\n" +
               student_pairing_array.join(',') + "\n")
    end
  end

  it '#attendees_emails' do
    workshop = Fabricate(:workshop)
    presenter = WorkshopPresenter.new(workshop)
    members = Fabricate.times(6, :member)
    members.each_with_index do |member, index|
      index % 2 == 0 ? Fabricate(:attending_workshop_invitation, member: member, workshop: workshop) :
        Fabricate(:attending_workshop_invitation, member: member, workshop: workshop, role: 'Coach')
    end

    expect(presenter.attendees_emails.split(', ')).to match_array(members.map(&:email))
  end

  context '#coach_spaces' do
    it 'returns the available coach_spots' do
      expect(host).to receive(:coach_spots)

      presenter.coach_spaces
    end
  end

  context '#student_spaces' do
    it 'returns the available coach_spots' do
      expect(host).to receive(:seats)

      presenter.student_spaces
    end
  end

  context '#spaces?' do
    let(:sponsor) { double(:sponsor, coach_spots: 3, seats: 5, chapter: chapter) }

    def double_workshop(attending_coaches:, attending_students:)
      double(:workshop, coach_spaces: 0, student_spaces: 0, host: sponsor,
                        attending_coaches: double(:attending_coaches, length: attending_coaches),
                        attending_students: double(:attending_students, length: attending_students))
    end


    context 'when the host has more available spots' do
      let(:workshop) { double_workshop(attending_coaches: 2, attending_students: 3) }

      it 'it returns true' do
        expect(presenter.spaces?).to eq(true)
      end
    end

    context 'when the host has no more available spots' do
      let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 5) }

      it 'it returns false' do
        expect(presenter.spaces?).to eq(false)
      end
    end
  end

  context '#send_attending_email' do
    it 'send an attending email to the invitation user' do
      workshop_invitation_mailer = double(:workshop_invitation_mailed, deliver_now: true)
      invitation = double(:invitation, member: double(:member))
      expect(WorkshopInvitationMailer)
        .to receive(:attending)
        .with(workshop, invitation.member, invitation, false)
        .and_return(workshop_invitation_mailer)

      presenter.send_attending_email(invitation)
    end

    it 'send a waiting list email to the invitation user' do
      workshop_invitation_mailer = double(:workshop_invitation_mailed, deliver_now: true)
      invitation = double(:invitation, member: double(:member))
      expect(WorkshopInvitationMailer)
        .to receive(:attending)
        .with(workshop, invitation.member, invitation, true)
        .and_return(workshop_invitation_mailer)

      presenter.send_attending_email(invitation, true)
    end
  end
end
