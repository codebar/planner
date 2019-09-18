require 'spec_helper'

describe Job, type: :model do
  context '#fields' do
    subject(:job) { Fabricate.build(:job) }

    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:location) }
    it { should respond_to(:expiry_date) }
    it { should respond_to(:email) }
    it { should respond_to(:link_to_job) }
    it { should respond_to(:expiry_date) }
    it { should respond_to(:created_by) }
    it { should respond_to(:approved) }
    it { should respond_to(:submitted) }
    it { should define_enum_for(:status).with_values(draft: 0, pending: 1, published: 2) }
  end

  context 'scopes' do
    let!(:approved) { 2.times.map { Fabricate(:published_job) } }
    let!(:drafts) { 1.times.map { Fabricate(:job) } }
    let!(:pending_approval) { 4.times.map { Fabricate(:pending_job) } }

    it '#active returns all active jobs' do
      2.times.map { Fabricate(:job, expiry_date: 1.week.ago) }

      expect(Job.active.to_a).to match_array(approved + drafts + pending_approval)
    end

    it '#pending_or_published returns all pending or published jobs' do
      expect(Job.pending_or_published.to_a).to match_array(approved + pending_approval)
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
end
