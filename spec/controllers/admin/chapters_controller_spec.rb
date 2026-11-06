require 'rails_helper'

RSpec.describe Admin::ChaptersController do
  let(:admin) { Fabricate(:member) }

  before do
    login_as_admin(admin)
  end

  describe '#create' do
    context 'when a chapter-scoped organiser creates a chapter' do
      let(:organiser) { Fabricate(:chapter_organiser) }

      before do
        login(organiser)
      end

      it 'is denied before anything is persisted' do
        expect do
          post :create, params: { chapter: {
            name: 'codebar Brighton',
            email: 'brighton@codebar.io',
            city: 'Brighton',
            time_zone: 'London'
          } }
        end.not_to(change { [Chapter.count, Group.count] })

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#status' do
    it 'renders successfully with default 6 months' do
      get :status
      expect(response).to be_successful
      expect(controller.view_assigns['months']).to eq(6)
    end

    it 'respects months param' do
      get :status, params: { months: '12' }
      expect(controller.view_assigns['months']).to eq(12)
    end

    it 'falls back to 6 for invalid months' do
      get :status, params: { months: '3' }
      expect(controller.view_assigns['months']).to eq(6)
    end

    it 'classifies chapters correctly' do
      get :status
      expect(controller.view_assigns['active']).to be_a(Array)
      expect(controller.view_assigns['dormant']).to be_a(Array)
      expect(controller.view_assigns['inactive']).to be_a(Array)
    end

    it 'marks a chapter with a past workshop as active' do
      chapter = Fabricate(:chapter_with_groups)
      Fabricate(:workshop, chapter:, date_and_time: 2.months.ago)

      get :status

      active_names = controller.view_assigns['active'].map { |r| r[:chapter].name }
      expect(active_names).to include(chapter.name)
    end

    it 'marks a chapter with only a future workshop as active' do
      chapter = Fabricate(:chapter_with_groups)
      Fabricate(:workshop, chapter:, date_and_time: 2.months.from_now)

      get :status

      active_names = controller.view_assigns['active'].map { |r| r[:chapter].name }
      expect(active_names).to include(chapter.name)
    end

    it 'marks an active:false chapter as inactive' do
      chapter = Fabricate(:chapter_with_groups, active: false)

      get :status

      inactive_names = controller.view_assigns['inactive'].map { |r| r[:chapter].name }
      expect(inactive_names).to include(chapter.name)
    end

    it 'flags at-risk chapters with no recent workshops' do
      chapter = Fabricate(:chapter_with_groups)
      Fabricate(:workshop, chapter:, date_and_time: 6.months.ago + 1.week)

      get :status, params: { months: '6' }

      expect(controller.view_assigns['at_risk_ids']).to include(chapter.id)
    end

    it 'does not flag active chapters with recent workshops as at-risk' do
      chapter = Fabricate(:chapter_with_groups)
      Fabricate(:workshop, chapter:, date_and_time: 1.month.ago)

      get :status, params: { months: '6' }

      expect(controller.view_assigns['at_risk_ids']).not_to include(chapter.id)
    end
  end

  describe '#show health section' do
    render_views

    it 'renders the chapter health section for admins' do
      login_as_admin(Fabricate(:member))
      chapter = Fabricate(:chapter)
      Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)

      get :show, params: { id: chapter.id }

      expect(response.body).to include('Chapter Health')
      expect(response.body).to include('Workshops and events timeline')
    end

    it 'shows the health section to chapter organisers too' do
      organiser = Fabricate(:chapter_organiser)
      login(organiser)

      get :show, params: { id: organiser.organised_chapters.first.id }

      expect(response).to be_successful
      expect(response.body).to include('Chapter Health')
    end

    it 'shows new sign-ups split across the last 3 months' do
      travel_to(Time.zone.local(2026, 11, 6, 12, 0)) do
        login_as_admin(Fabricate(:member))
        chapter = Fabricate(:chapter)
        students = Fabricate(:group, name: 'Students', chapter:)
        coaches = Fabricate(:group, name: 'Coaches', chapter:)
        Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 9, 10))
        Fabricate(:subscription, group: coaches, created_at: Time.zone.local(2026, 10, 10))
        Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 11, 2))
        Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 8, 20))

        get :show, params: { id: chapter.id }

        expect(response.body).to include('New sign-ups (last 3 months)')
        expected = [
          { month: Date.new(2026, 9, 1), students: 1, coaches: 0 },
          { month: Date.new(2026, 10, 1), students: 0, coaches: 1 },
          { month: Date.new(2026, 11, 1), students: 1, coaches: 0 }
        ]
        expect(controller.view_assigns['new_sign_ups']).to eq(expected)
      end
    end
  end
end
