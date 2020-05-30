require 'spec_helper'

RSpec.describe JobPresenter do
  let(:presenter) { JobPresenter.new(job) }

  context '#published_on' do
    let(:job) { Fabricate(:published_job) }

    it 'returns the localised published on date if set' do
      published_on = I18n.l(job.published_on, format: :date)

      expect(presenter.published_on).to eq(published_on)
    end

    it 'returns the localised published on date if set' do
      job.update_attribute(:published_on, nil)

      expect(presenter.published_on).to eq('-')
    end
  end

  context '#published_on_time_iso8601' do
    let(:published_on) { Time.zone.now }
    let(:job) { Fabricate(:published_job, published_on: published_on) }

    it 'returns the published_on datetime converted to ixo8601 format ' do
      expect(presenter.published_on_time_iso8601).to eq(published_on.to_time.iso8601)
    end
  end

  context '#link_to_job' do
    let(:job) { Fabricate(:pending_job, link_to_job: "<script>test;</script>http://link.test") }

    it 'sanitizes the user supplied job link' do
      expect(presenter.link_to_job).to eq('test;http://link.test')
    end
  end

  context '#location_or_remote' do
    let(:job) { Fabricate(:job, remote: false, location: 'London') }

    it 'returns the location if the job is not remote' do
      expect(presenter.location_or_remote).to eq('London')
    end

    it 'returns remote if remote is set to true' do
      job.update_attribute(:remote, true)

      expect(presenter.location_or_remote).to eq('Remote')
    end
  end
end
