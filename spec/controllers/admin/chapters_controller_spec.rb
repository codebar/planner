RSpec.describe Admin::ChaptersController, type: :controller do
  let(:admin) { Fabricate(:member) }

  before do
    login_as_admin(admin)
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
      Fabricate(:workshop, chapter: chapter, date_and_time: 2.months.ago)

      get :status

      active_names = controller.view_assigns['active'].map { |r| r[:chapter].name }
      expect(active_names).to include(chapter.name)
    end

    it 'marks a chapter with only a future workshop as active' do
      chapter = Fabricate(:chapter_with_groups)
      Fabricate(:workshop, chapter: chapter, date_and_time: 2.months.from_now)

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
      Fabricate(:workshop, chapter: chapter, date_and_time: 6.months.ago + 1.week)

      get :status, params: { months: '6' }

      expect(controller.view_assigns['at_risk_ids']).to include(chapter.id)
    end

    it 'does not flag active chapters with recent workshops as at-risk' do
      chapter = Fabricate(:chapter_with_groups)
      Fabricate(:workshop, chapter: chapter, date_and_time: 1.month.ago)

      get :status, params: { months: '6' }

      expect(controller.view_assigns['at_risk_ids']).not_to include(chapter.id)
    end
  end
end
