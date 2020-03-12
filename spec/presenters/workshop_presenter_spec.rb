require 'spec_helper'

RSpec.describe WorkshopPresenter do
  let(:invitations) do
    [Fabricate(:student_workshop_invitation),
     Fabricate(:student_workshop_invitation),
     Fabricate(:coach_workshop_invitation),
     Fabricate(:coach_workshop_invitation)]
  end
  let(:chapter) { Fabricate(:chapter) }
  let(:workshop_double) do
    double(:workshop, time: Time.zone.now, ends_at: 1.hour.from_now,
           attendances: invitations, host: Fabricate(:sponsor), chapter: chapter)
  end
  let(:workshop) { WorkshopPresenter.new(workshop_double) }

  it '#venue' do
    expect(workshop_double).to receive(:host)

    workshop.venue
  end

  it '#organisers' do
    expect(workshop_double).to receive(:permissions)
    expect(workshop_double).to receive(:chapter).and_return(chapter)

    workshop.organisers
  end

  it '#time' do
    start_time = workshop_double.time
    expect(workshop.time).to eq(I18n.l(start_time, format: :time))
  end

  it '#end_time' do
    expect(workshop.end_time).to eq(I18n.l(workshop_double.ends_at, format: :time))
  end

  context 'start_and_end_time' do
    it 'when no end_time is set it only returns the start_time' do
      workshop_double =  double(:workshop, time: Time.zone.now, ends_at: nil)
      workshop = WorkshopPresenter.new(workshop_double)

      expect(workshop.start_and_end_time).to eq(I18n.l(workshop_double.time, format: :time))
    end

    it 'when a start and end_time are set it returns a formatted start and end_time' do
      workshop_double =  double(:workshop, time: Time.zone.now, ends_at: 1.hour.from_now)
      workshop = WorkshopPresenter.new(workshop_double)

      expect(workshop.start_and_end_time)
        .to eq("#{I18n.l(workshop_double.time, format: :time)} - #{I18n.l(workshop_double.ends_at, format: :time)}")
    end
  end

  it '#attendees_csv' do
    expect(workshop).to receive(:organisers).at_least(:once).and_return [invitations.last.member]
    expect(workshop.attendees_csv).not_to be_blank

    invitations.each do |invitation|
      expect(workshop.attendees_csv).to include(invitation.member.full_name)
      expect(workshop.attendees_csv).to include(invitation.role.upcase).or include('ORGANISER')
    end
    expect(workshop.attendees_csv).to include('ORGANISER')
    expect(workshop.attendees_csv).to include('STUDENT')
    expect(workshop.attendees_csv).to include('COACH')
  end

  it '#attendees_emails' do
    workshop = Fabricate(:workshop)
    presenter = WorkshopPresenter.new(workshop)
    members = Fabricate.times(6, :member)
    members.each_with_index do |member, index|
      index % 2 == 0 ? Fabricate(:attending_workshop_invitation, member: member,  workshop: workshop) :
                       Fabricate(:attending_workshop_invitation, member: member,  workshop: workshop, role: 'Coach')
    end

    expect(presenter.attendees_emails.split(', ')).to match_array(members.map(&:email))
  end
end
