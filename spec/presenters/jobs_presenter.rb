require 'spec_helper'

describe JobsPresenter do
  let(:presenter) { JobsPresenter.new(jobs) }
  let(:jobs) { Fabricate.times(4, :job) }

  context '#each' do
    it 'is delegated to the decorated collection' do
      decorated_jobs = jobs.map { |v| JobPresenter.new(v) }

      allow(presenter).to receive(:decorated_collection).and_return(decorated_jobs)
      expect(decorated_jobs).to receive(:each)

      presenter.each {}
    end
  end
end
