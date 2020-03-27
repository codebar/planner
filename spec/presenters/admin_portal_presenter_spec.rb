require 'spec_helper'

RSpec.describe AdminPortalPresenter do
  describe '#chapters' do
    it 'includes active chapters' do
      active_chapter = Fabricate(:chapter, active: true)

      expect(subject.active_chapters).to include(active_chapter)
    end

    it 'excludes inactive chapters' do
      inactive_chapter = Fabricate(:chapter, active: false)

      expect(subject.active_chapters).not_to include(inactive_chapter)
    end
  end

  describe '#jobs_pending_approval' do
    it 'includes submitted jobs that are not approved' do
      Fabricate(:pending_job, approved: false, submitted: true)

      expect(subject.jobs_pending_approval).to eq 1
    end

    it 'excludes submitted jobs that have been approved' do
      Fabricate(:published_job, approved: true, submitted: true)

      expect(subject.jobs_pending_approval).to eq 0
    end
  end

  describe '#workshops_upcoming' do
    it 'includes upcoming workshops' do
      upcoming_workshop = Fabricate(:workshop, date_and_time: Time.zone.now + 2.days)

      expect(subject.upcoming_workshops).to include(upcoming_workshop)
    end

    it 'excludes past workshops' do
      past_workshop = Fabricate(:past_workshop, date_and_time: Time.zone.now - 2.days)

      expect(subject.upcoming_workshops).not_to include(past_workshop)
    end
  end

  describe '#active_chapter_groups' do
    it 'includes groups with active chapters' do
      active_chaptered_group = Fabricate(:group, chapter: Fabricate(:chapter, active: true))

      expect(subject.active_chapter_groups).to include(active_chaptered_group)
    end

    it 'excludes groups without active chapters' do
      inactive_chaptered_group = Fabricate(:group, chapter: Fabricate(:chapter, active: false))

      expect(subject.active_chapter_groups).not_to include(inactive_chaptered_group)
    end
  end

  describe '#subscribers' do
    it 'includes subscribers of the active chapters' do
      without_bullet do
        chapter = Fabricate(:chapter_with_groups, active: true)

        expect(subject.subscribers).to match_array(chapter.subscriptions)
      end
    end

    it 'excludes subscribers not associated with active chapters' do
      without_bullet do
        chapter = Fabricate(:chapter_with_groups, active: false)

        expect(subject.subscribers).not_to match_array(chapter.subscriptions)
      end
    end
  end
end
