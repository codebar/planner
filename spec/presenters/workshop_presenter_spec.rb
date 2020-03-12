require 'spec_helper'

RSpec.describe WorkshopPresenter do
  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { double(:workshop, host: Fabricate(:sponsor), chapter: chapter) }
  let(:presenter) { WorkshopPresenter.new(workshop) }

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

      it 'when a start and end_time are set it returns a formatted start and end_time' do
        workshop =  double(:workshop, time: Time.zone.now, ends_at: 1.hour.from_now)
        presenter = WorkshopPresenter.new(workshop)

        expect(presenter.start_and_end_time)
          .to eq("#{I18n.l(workshop.time, format: :time)} - #{I18n.l(workshop.ends_at, format: :time)}")
      end
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
end
