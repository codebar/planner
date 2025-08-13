RSpec.describe ChapterPresenter do
  let(:chapter) { Fabricate(:chapter_without_organisers) }
  let(:presenter) { ChapterPresenter.new(chapter) }

  it '#upcoming_workshops' do
    Fabricate.times(2, :past_workshop, chapter: chapter)
    workshops = Fabricate.times(3, :workshop, chapter: chapter,
                                              date_and_time: Time.zone.now + 1.week)

    expect(presenter.upcoming_workshops).to match_array(workshops)
  end

  it '#organisers' do
    permissions = Fabricate(:permission, resource: chapter, name: 'organiser')

    expect(presenter.organisers).to match_array(permissions.members)
  end
end
