require 'spec_helper'

RSpec.describe Job, type: :model do
  context '#fields' do
    subject(:job) { Fabricate.build(:job) }

    it { should define_enum_for(:status).with_values(draft: 0, pending: 1, published: 2) }
  end

  context 'scopes' do
    context '#active' do
      it 'excludes expired jobs' do
        expired_job = Fabricate(:job, expiry_date: 1.week.ago)

        expect(Job.active).not_to include(expired_job)
      end

      it 'includes active job' do
        active_job = Fabricate(:job, expiry_date: 1.week.since)

        expect(Job.active).to include(active_job)
      end
    end

    context '#pending_or_published' do
      it 'excludes draft jobs' do
        draft_job = Fabricate(:job, status: :draft)

        expect(Job.pending_or_published).not_to include(draft_job)
      end

      it 'includes pending jobs' do
        pending = Fabricate(:pending_job)

        expect(Job.pending_or_published).to include(pending)
      end

      it 'includes published jobs' do
        published = Fabricate(:published_job)

        expect(Job.pending_or_published).to include(published)
      end
    end
  end

  context '#expired?' do
    it 'checks if the job post has past its expiry_date' do
      job = Job.new(expiry_date: 1.day.ago)

      expect(job.expired?).to eq(true)
    end
  end

  context "#approve!" do
    it 'approves a job' do
      approver = Fabricate(:member)
      job = Fabricate(:pending_job)
      now = Time.zone.now

      job.approve!(approver)

      expect(job.approved_by).to eq(approver)
      expect(job.approved).to eq(true)
      expect(job.published_on).to_not be_nil
      expect(job.status).to eq('published')
    end
  end

  context "#unpublish!" do
    it 'unpublishes a job' do
      job = Fabricate(:published_job)

      job.unpublish!

      expect(job.approved_by).to be_nil
      expect(job.published_on).to be_nil
      expect(job.approved).to eq(false)
      expect(job.status).to eq('pending')
    end
  end
end
