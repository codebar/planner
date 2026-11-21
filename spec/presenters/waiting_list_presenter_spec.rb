require 'rails_helper'

RSpec.describe WaitingListPresenter do
  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do
      queries += 1
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  let(:workshop) { Fabricate(:workshop) }
  let(:auto_rsvp_invitation) { Fabricate(:workshop_invitation, workshop:) }
  let(:reminder_invitation) { Fabricate(:workshop_invitation, workshop:) }
  let(:presenter) { described_class.new(WaitingList.students_for(workshop)) }

  before do
    WaitingList.add(auto_rsvp_invitation)
    WaitingList.add(reminder_invitation, false)
  end

  describe '#list' do
    it 'holds only the entries queued for automatic booking' do
      expect(presenter.list.map(&:invitation)).to eq([auto_rsvp_invitation])
    end

    it 'is empty when nothing books automatically' do
      empty_workshop = Fabricate(:workshop)
      WaitingList.add(Fabricate(:workshop_invitation, workshop: empty_workshop), false)

      queue = described_class.new(WaitingList.students_for(empty_workshop)).list

      expect(queue).to be_empty
    end

    it 'does not query again when read twice' do
      one_read = count_queries { presenter.list.to_a }
      two_reads = count_queries { 2.times { presenter.list.to_a } }

      expect(two_reads).to be <= one_read
    end
  end

  describe '#reminders' do
    it 'holds only the entries still awaiting a reminder' do
      expect(presenter.reminders.map(&:invitation)).to eq([reminder_invitation])
    end
  end
end
