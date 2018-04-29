require 'spec_helper'

describe ChapterPresenter do
  let(:chapter) { Fabricate(:chapter) }
  let(:presenter) { ChapterPresenter.new(chapter) }

  it '#twitter_id' do
    expect(chapter).to receive(:twitter_id)

    presenter.twitter_id
  end

  it '#twitter_handle' do
    expect(chapter).to receive(:twitter)

    presenter.twitter
  end

  it '#upcoming_workshops' do
    workshops = double(:workshops, upcoming: [double(:workshop, date_and_time: Time.zone.now)])
    expect(chapter).to receive(:workshops).and_return(workshops)

    presenter.upcoming_workshops
  end

  it '#organisers' do
    permissions = Fabricate(:permission, resource: chapter, name: 'organiser')

    expect(presenter.organisers).to eq(permissions.members)
  end
end
